using AutoMapper;
using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.DTOs.AdminStore;
using BeautyBookingSystem.Application.DTOs.Common;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using AutoMapper.QueryableExtensions;
using BeautyBookingSystem.Domain.Constants;

namespace BeautyBookingSystem.Application.Services
{
    public class AdminStoreService : IAdminStoreService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly INotificationService _notificationService;

        public AdminStoreService(IUnitOfWork unitOfWork, IMapper mapper, INotificationService notificationService)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _notificationService = notificationService;
        }

    public async Task<PagedResponse<StoreAdminDto>> GetStoresAsync(StoreFilterRequest request)
{
    var query = _unitOfWork.StoreRepository.GetQueryable();
    if (!string.IsNullOrWhiteSpace(request.SearchTerm))
    {
        var search = request.SearchTerm.ToLower();
        query = query.Where(s => s.Name.ToLower().Contains(search) ||
                                 s.Phone.Contains(search));
    }

    if (request.Status.HasValue)
    {
        query = query.Where(s => s.ApprovalStatus == request.Status.Value);
    }
    if (request.IsDebt.HasValue && request.IsDebt.Value)
    {
       query = query.Where(s => s.WalletBalance < 0);
    }

    int totalCount = await query.CountAsync();

    var stores = await query
        .OrderByDescending(s => s.CreatedAt)
        .Skip((request.PageIndex - 1) * request.PageSize)
        .Take(request.PageSize)
        .ProjectTo<StoreAdminDto>(_mapper.ConfigurationProvider) 
        .ToListAsync();

    return new PagedResponse<StoreAdminDto>
    {
        Items = stores,
        TotalCount = totalCount,
        TotalPages = (int)Math.Ceiling(totalCount / (double)request.PageSize)
    };
}

        public async Task<StoreAdminDetailDto?> GetStoreByIdAsync(int id)
        {
            return await _unitOfWork.StoreRepository.GetQueryable()
                .Where(s => s.Id == id)
                .ProjectTo<StoreAdminDetailDto>(_mapper.ConfigurationProvider)
                .FirstOrDefaultAsync();
        }

      public async Task<bool> ApproveStoreAsync(int id, ApproveStoreRequest request)
        {
            var store = await _unitOfWork.StoreRepository.GetByIdAsync(id);
            if (store == null) throw new NotFoundException("Không tìm thấy cửa hàng.");

            if (store.ApprovalStatus != ApprovalStatus.Pending)
                throw new BadRequestException("Chỉ có thể duyệt các cửa hàng đang ở trạng thái Chờ (Pending).");

            store.ApprovalStatus = request.IsApproved ? ApprovalStatus.Approved : ApprovalStatus.Locked;
            
            int freeTrialDays = 0;
            decimal monthlyFee = 0;

            if (request.IsApproved)
            {
                var trialConfig = await _unitOfWork.SystemConfigRepository.GetQueryable()
                    .FirstOrDefaultAsync(c => c.Key == SystemConfigKeys.FreeTrialDays); 
                    
                if (trialConfig != null && int.TryParse(trialConfig.Value, out var parsedDays))
                {
                    freeTrialDays = parsedDays;
                }
                else
                {
                    freeTrialDays = 30; 
                }
                
                store.NextBillingDate = DateTime.UtcNow.AddDays(freeTrialDays);

                if (store.MonthlyAppFee > 0)
                {
                    monthlyFee = store.MonthlyAppFee;
                }
                else
                {
                    var feeConfig = await _unitOfWork.SystemConfigRepository.GetQueryable()
                        .FirstOrDefaultAsync(c => c.Key == "DefaultMonthlyAppFee");
                        
                    monthlyFee = feeConfig != null && decimal.TryParse(feeConfig.Value, out var parsedFee) 
                                 ? parsedFee 
                                 : 50000m;
                    store.MonthlyAppFee = monthlyFee; 
                }
            }

            _unitOfWork.StoreRepository.Update(store);
            var result = await _unitOfWork.SaveChangesAsync() > 0;
            
            if (result)
            {
                string title;
                string message;

                if (request.IsApproved)
                {
                    title = "Cửa hàng đã được duyệt!";
                    
                    var billingDateStr = store.NextBillingDate?.AddHours(7).ToString("dd/MM/yyyy");

                    message = $"Chúc mừng! Cửa hàng '{store.Name}' của bạn đã được phê duyệt. " +
                              $"Bạn được tặng {freeTrialDays} ngày dùng thử miễn phí. " +
                              $"Hệ thống sẽ bắt đầu thu phí nền tảng ({monthlyFee:N0}đ/tháng) từ ngày {billingDateStr}. " +
                              $"Vui lòng đảm bảo số dư ví để không bị gián đoạn dịch vụ.";
                }
                else
                {
                    title = "Yêu cầu mở cửa hàng bị từ chối";
                    message = $"Rất tiếc, yêu cầu mở cửa hàng '{store.Name}' của bạn đã bị từ chối. Vui lòng liên hệ quản trị viên để biết thêm chi tiết.";
                }

                await _notificationService.CreateAndSendNotificationAsync(
                    store.OwnerId,
                    title,
                    message,
                    NotificationType.SystemAlert 
                );
            }
            
            return result;
        }
        public async Task<bool> ChangeStoreStatusAsync(int id, UpdateStoreStatusRequest request)
        {
            var store = await _unitOfWork.StoreRepository.GetByIdAsync(id);
            if (store == null) throw new NotFoundException("Không tìm thấy cửa hàng.");

            store.ApprovalStatus = request.NewStatus;

            _unitOfWork.StoreRepository.Update(store);
            var result = await _unitOfWork.SaveChangesAsync() > 0;

            if (result)
            {
                string title = "Trạng thái cửa hàng thay đổi";
                string message = request.NewStatus == ApprovalStatus.Locked
                    ? $"⚠️Cửa hàng '{store.Name}' của bạn đã bị tạm khóa. Bạn sẽ không thể nhận thêm lịch hẹn mới."
                    : $"✅Cửa hàng '{store.Name}' của bạn đã được mở khóa và có thể hoạt động bình thường trở lại.";

                await _notificationService.CreateAndSendNotificationAsync(
                    store.OwnerId,
                    title,
                    message,
                    NotificationType.SystemAlert
                );
            }
            return result;
        }
        public async Task<bool> UpdateStoreFeeConfigAsync(int id, UpdateStoreFeeConfigRequest request)
        {
            var store = await _unitOfWork.StoreRepository.GetByIdAsync(id);
            if (store == null) throw new NotFoundException("Không tìm thấy cửa hàng.");

            store.CommissionRate = request.CommissionRate;
            store.MonthlyAppFee = request.MonthlyAppFee;

            _unitOfWork.StoreRepository.Update(store);
            return await _unitOfWork.SaveChangesAsync() > 0;
        }

        public async Task<IEnumerable<StoreDropdownDto>> GetStoresForDropdownAsync()
        {
            return await _unitOfWork.StoreRepository.GetQueryable()
                .Where(s => s.ApprovalStatus == ApprovalStatus.Approved)
                .Select(s => new StoreDropdownDto
                {
                    Id = s.Id,
                    Name = s.Name
                })
                .ToListAsync();
        }
    }
}
