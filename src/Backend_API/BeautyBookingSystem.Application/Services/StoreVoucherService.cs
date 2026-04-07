using AutoMapper;
using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.DTOs.StoreVoucher;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Services
{
    public class StoreVoucherService : IStoreVoucherService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUserService _currentUserService;
        private readonly IMapper _mapper;
        private readonly INotificationService _notificationService;

        public StoreVoucherService(IUnitOfWork unitOfWork, ICurrentUserService currentUserService, IMapper mapper, INotificationService notificationService)
        {
            _unitOfWork = unitOfWork;
            _currentUserService = currentUserService;
            _mapper = mapper;
            _notificationService = notificationService;
        }

        private async Task<Voucher> GetAndValidateOwnershipAsync(int voucherId, int storeId)
        {
            var voucher = await _unitOfWork.VoucherRepository.GetQueryable()
                .FirstOrDefaultAsync(v => v.Id == voucherId);

            if (voucher == null || voucher.StoreId != storeId)
                throw new NotFoundException("Khuyến mãi không tồn tại hoặc không thuộc quyền quản lý của bạn.");

            return voucher;
        }

        public async Task<List<VoucherDto>> GetAllVouchersAsync()
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();
            var vouchers = await _unitOfWork.VoucherRepository.GetQueryable()
                .Include(v => v.Service)
                .Where(v => v.StoreId == storeId)
                .OrderByDescending(v => v.Id)
                .ToListAsync();

            return _mapper.Map<List<VoucherDto>>(vouchers);
        }

        public async Task<VoucherDto> GetVoucherByIdAsync(int id)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();
            var voucher = await GetAndValidateOwnershipAsync(id, storeId);
            return _mapper.Map<VoucherDto>(voucher);
        }

        public async Task<VoucherDto> CreateVoucherAsync(CreateVoucherRequest request)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();

            if (request.EndDate <= request.StartDate)
                throw new BadRequestException("Ngày kết thúc phải lớn hơn ngày bắt đầu.");

            var isCodeExist = await _unitOfWork.VoucherRepository.GetQueryable()
                .AnyAsync(v => v.StoreId == storeId && v.Code.ToLower() == request.Code.ToLower());
            if (isCodeExist)
                throw new BadRequestException($"Mã khuyến mãi '{request.Code}' đã tồn tại trong cửa hàng của bạn.");

            if (request.ServiceId.HasValue)
            {
                var isValidService = await _unitOfWork.ServiceRepository.GetQueryable()
                    .AnyAsync(s => s.Id == request.ServiceId.Value && s.StoreId == storeId);

                if (!isValidService)
                    throw new BadRequestException("Dịch vụ không tồn tại hoặc không thuộc cửa hàng của bạn.");
            }
            var voucher = new Voucher
            {
                StoreId = storeId,
                ServiceId = request.ServiceId,
                Code = request.Code.ToUpper(), 
                DiscountType = request.DiscountType,
                DiscountValue = request.DiscountValue,
                MinOrderValue = request.MinOrderValue,
                MaxDiscount = request.MaxDiscount,
                StartDate = request.StartDate,
                EndDate = request.EndDate,
                UsageLimit = request.UsageLimit,
                UsedCount = 0 
            };

            await _unitOfWork.VoucherRepository.AddAsync(voucher);
            var result = await _unitOfWork.SaveChangesAsync() > 0;

            if (result)
            {
                var customerIds = await _unitOfWork.BookingRepository.GetQueryable()
                    .Where(b => b.StoreId == storeId)
                    .Select(b => b.CustomerId)
                    .Distinct()
                    .ToListAsync();

                var store = await _unitOfWork.StoreRepository.GetByIdAsync(storeId);
                if (customerIds.Any())
                {
                    foreach (var customerId in customerIds)
                    {
                        await _notificationService.CreateAndSendNotificationAsync(
                            customerId,
                            $"🎁 Ưu đãi mới từ {store?.Name}",
                            $"Nhập mã {voucher.Code} để được giảm giá ngay cho lần đặt lịch tiếp theo!",
                            NotificationType.Promotion
                        );
                    }
                }
            }

            return _mapper.Map<VoucherDto>(voucher);
        }

        public async Task<bool> UpdateVoucherAsync(int id, UpdateVoucherRequest request)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();
            var voucher = await GetAndValidateOwnershipAsync(id, storeId);

            if (request.EndDate <= voucher.StartDate)
                throw new BadRequestException("Ngày kết thúc mới không được nhỏ hơn ngày bắt đầu.");

            voucher.EndDate = request.EndDate;
            voucher.UsageLimit = request.UsageLimit;

            _unitOfWork.VoucherRepository.Update(voucher);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<bool> DeleteVoucherAsync(int id)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();
            var voucher = await GetAndValidateOwnershipAsync(id, storeId);

            if (voucher.UsedCount > 0)
                throw new BadRequestException("Khuyến mãi này đã có khách hàng sử dụng, không thể xóa. " +
                    "Vui lòng cập nhật Ngày kết thúc để dừng khuyến mãi.");

            _unitOfWork.VoucherRepository.Delete(voucher);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }
    }
}
