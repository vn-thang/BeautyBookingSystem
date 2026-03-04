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

        //Lấy danh sách (Bao gồm cả lấy danh sách Pending nếu request.Status = Pending)
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
            
            _unitOfWork.StoreRepository.Update(store);
            var result = await _unitOfWork.SaveChangesAsync() > 0;
            if (result)
            {
                string title = request.IsApproved ? "✅Cửa hàng đã được duyệt!" : "❌Yêu cầu mở cửa hàng bị từ chối";
                string message = request.IsApproved
                    ? $"Chúc mừng! Cửa hàng '{store.Name}' của bạn đã được quản trị viên phê duyệt. Bạn có thể bắt đầu thiết lập dịch vụ ngay bây giờ."
                    : $"Rất tiếc, yêu cầu mở cửa hàng '{store.Name}' của bạn đã bị từ chối. Vui lòng liên hệ quản trị viên để biết thêm chi tiết.";

                _ = _notificationService.CreateAndSendNotificationAsync(
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
    }
}
