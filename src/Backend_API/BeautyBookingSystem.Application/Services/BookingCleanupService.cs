using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Services
{
    public class BookingCleanupService : IBookingCleanupService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly INotificationService _notificationService;

        public BookingCleanupService(IUnitOfWork unitOfWork, INotificationService notificationService)
        {
            _unitOfWork = unitOfWork;
            _notificationService = notificationService;
        }

        public async Task CancelExpiredPendingBookingsAsync()
        {
            var expiredTime = DateTime.UtcNow.AddMinutes(-15);

            var expiredBookings = await _unitOfWork.BookingRepository
                .GetQueryable()
                .Include(b => b.Payments)
                .Include(b => b.BookingDetails)
                .Where(b => b.Status == BookingStatus.Pending 
                         && b.CreatedAt <= expiredTime
                         && !b.Payments.Any(p => p.PaymentMethod == PaymentMethod.COD)) 
                .ToListAsync();

            if (!expiredBookings.Any()) return; 

            foreach (var booking in expiredBookings)
            {
                booking.Status = BookingStatus.Cancelled;
                booking.CancelledBy = CancelledByType.Admin; 
                booking.CancelReason = "Hệ thống tự động hủy do đơn hàng không hoàn tất thanh toán VNPay trong 15 phút.";

                foreach (var detail in booking.BookingDetails)
                {
                    detail.Status = BookingDetailStatus.Cancelled;
                }

                var pendingPayments = booking.Payments.Where(p => p.Status == PaymentStatus.Pending);
                foreach (var payment in pendingPayments)
                {
                    payment.Status = PaymentStatus.Failed;
                }

                if (booking.VoucherId.HasValue && booking.DiscountAmount > 0)
                {
                    var voucher = await _unitOfWork.VoucherRepository.GetByIdAsync(booking.VoucherId.Value);
                    if (voucher != null && voucher.UsedCount > 0)
                    {
                        voucher.UsedCount--;
                        _unitOfWork.VoucherRepository.Update(voucher);
                    }
                }

                _unitOfWork.BookingRepository.Update(booking);
                 if (booking.CustomerId.HasValue)
                {
                await _notificationService.CreateAndSendNotificationAsync(
                    booking.CustomerId.Value,
                    "⏰ Lịch hẹn đã bị hủy",
                    $"Lịch hẹn #{booking.Id} đã tự động hủy do chưa hoàn tất thanh toán. Vui lòng đặt lại lịch mới nhé!",
                    NotificationType.SystemAlert
                );
            }
            }
            await _unitOfWork.SaveChangesAsync();
        }
    }
}