using AutoMapper;
using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.DTOs.StorePayment;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace BeautyBookingSystem.Application.Services
{
    public class StorePaymentService : IStorePaymentService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly ICurrentUserService _currentUserService;
        private readonly INotificationService _notificationService;

        public StorePaymentService(IUnitOfWork unitOfWork, IMapper mapper, ICurrentUserService currentUserService, INotificationService notificationService)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _currentUserService = currentUserService;
            _notificationService = notificationService;
        }

        public async Task<List<StorePaymentListDto>> GetPaymentsAsync(PaymentFilterRequest request)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();
            var query = _unitOfWork.PaymentRepository.GetQueryable()
                .Include(p => p.Booking)
                    .ThenInclude(b => b.Customer) 
                .Where(p => p.Booking.StoreId == storeId);

            if (request.FromDate.HasValue)
                query = query.Where(p => p.PaidAt >= request.FromDate.Value || p.Booking.CreatedAt >= request.FromDate.Value);

            if (request.ToDate.HasValue)
                query = query.Where(p => p.PaidAt <= request.ToDate.Value || p.Booking.CreatedAt <= request.ToDate.Value);

            if (!string.IsNullOrEmpty(request.PaymentMethod) && Enum.TryParse<PaymentMethod>(request.PaymentMethod, true, out var methodEnum))
                query = query.Where(p => p.PaymentMethod == methodEnum);

            if (!string.IsNullOrEmpty(request.Status) && Enum.TryParse<PaymentStatus>(request.Status, true, out var statusEnum))
                query = query.Where(p => p.Status == statusEnum);

            var payments = await query.OrderByDescending(p => p.Id).ToListAsync();
            return _mapper.Map<List<StorePaymentListDto>>(payments);
        }

        public async Task<bool> ConfirmPaymentAsync(int paymentId, ConfirmPaymentRequest request)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();

            var payment = await _unitOfWork.PaymentRepository.GetQueryable()
                .Include(p => p.Booking)
                .FirstOrDefaultAsync(p => p.Id == paymentId && p.Booking.StoreId == storeId);

            if (payment == null)
                throw new NotFoundException("Không tìm thấy giao dịch này.");

            if (payment.Booking.Status == BookingStatus.Pending)
            {
                throw new BadRequestException("Không thể thanh toán cho đơn đặt lịch chưa được duyệt!");
            }

            if (payment.Status == PaymentStatus.Success)
                throw new Exception("Giao dịch này đã được thanh toán rồi.");

            payment.Status = PaymentStatus.Success;
            payment.PaidAt = DateTime.UtcNow;

            if (!string.IsNullOrEmpty(request.TransactionId))
                payment.TransactionId = request.TransactionId;

            _unitOfWork.PaymentRepository.Update(payment);
            var result = await _unitOfWork.SaveChangesAsync() > 0;

            if (result)
            {
                _ = _notificationService.CreateAndSendNotificationAsync(
                    payment.Booking.CustomerId,
                    "Xác nhận thanh toán",
                    $"Giao dịch cho đơn hàng #{payment.BookingId} đã được xác nhận thành công. Cảm ơn bạn đã sử dụng dịch vụ!",
                    NotificationType.SystemAlert
                );
            }

            return result;
        }

        public async Task<bool> RefundPaymentAsync(int paymentId)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();

            var payment = await _unitOfWork.PaymentRepository.GetQueryable()
                .Include(p => p.Booking)
                .FirstOrDefaultAsync(p => p.Id == paymentId && p.Booking.StoreId == storeId);

            if (payment == null)
                throw new NotFoundException("Không tìm thấy giao dịch này.");

            if (payment.Status != PaymentStatus.Success)
                throw new Exception("Giao dịch chưa thành công, không thể hoàn tiền.");

            payment.Status = PaymentStatus.Refunded;

            _unitOfWork.PaymentRepository.Update(payment);
            var result = await _unitOfWork.SaveChangesAsync() > 0;

            if (result)
            {
                _ = _notificationService.CreateAndSendNotificationAsync(
                    payment.Booking.CustomerId,
                    "🔄Thông báo hoàn tiền",
                    $"Số tiền của giao dịch #{payment.Id} đã được hoàn lại. Vui lòng kiểm tra tài khoản của bạn.",
                    NotificationType.SystemAlert
                );
            }

            return result;
        }
    }
}
