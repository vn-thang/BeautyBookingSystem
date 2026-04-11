using BeautyBookingSystem.Application.DTOs.Payments;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.AspNetCore.Http;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Services
{
    public class CustomerPaymentService : ICustomerPaymentService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICustomerVnPayService _vnPayService;
        private readonly INotificationService _notificationService; 
        public CustomerPaymentService(
            IUnitOfWork unitOfWork, 
            ICustomerVnPayService vnPayService,
            INotificationService notificationService) 
        {
            _unitOfWork = unitOfWork;
            _vnPayService = vnPayService;
            _notificationService = notificationService;
        }

        public async Task<PaymentCreationResult> CreatePaymentAsync(CreatePaymentRequest req, string ipAddress)
        {
            if (req.BookingId <= 0) throw new Exception("BookingId invalid");
            if (req.Amount <= 0) throw new Exception("Amount invalid");

            var booking = await _unitOfWork.BookingRepository.GetByIdWithDetailsAsync(req.BookingId);
            if (booking == null) throw new Exception("Booking not found");

            var successfulPayments = booking.Payments.Where(p => p.Status == PaymentStatus.Success).ToList();
            var paidAmount = successfulPayments.Sum(p => p.Amount);
            var remainingAmount = booking.FinalPrice - paidAmount;
            if (remainingAmount < 0) remainingAmount = 0;

            PaymentType ResolvePaymentType(decimal amount)
            {
                if (booking.DepositAmount > 0 && successfulPayments.Count == 0 && amount == booking.DepositAmount)
                    return PaymentType.Deposit;
                if (amount == booking.FinalPrice || amount == remainingAmount)
                    return PaymentType.Full;

                throw new Exception("Số tiền thanh toán không hợp lệ");
            }

            var paymentType = ResolvePaymentType(req.Amount);

            var pendingPayments = booking.Payments
                .Where(p => p.Status == PaymentStatus.Pending)
                .OrderByDescending(p => p.Id)
                .ToList();

            Payment activePayment;

            if (pendingPayments.Any())
            {
                activePayment = pendingPayments.First();
                
                foreach (var oldPending in pendingPayments.Skip(1))
                {
                    oldPending.Status = PaymentStatus.Failed;
                    _unitOfWork.PaymentRepository.Update(oldPending);
                }

                activePayment.Amount = req.Amount;
                activePayment.PaymentMethod = req.PaymentMethod;
                activePayment.PaymentType = paymentType;
                _unitOfWork.PaymentRepository.Update(activePayment);
            }
            else
            {
                activePayment = new Payment
                {
                    BookingId = booking.Id,
                    Amount = req.Amount,
                    PaymentMethod = req.PaymentMethod,
                    PaymentType = paymentType,
                    Status = PaymentStatus.Pending
                };
                await _unitOfWork.PaymentRepository.AddAsync(activePayment);
            }

            await _unitOfWork.SaveChangesAsync();
            var url = _vnPayService.CreatePaymentUrl(activePayment, req, ipAddress);

            return new PaymentCreationResult
            {
                Url = url,
                PaymentId = activePayment.Id,
                BookingId = activePayment.BookingId,
                Amount = req.Amount
            };
        }

        public async Task<(bool Success, string Message)> ProcessVnpayCallbackAsync(IQueryCollection query)
        {
            var vnPayResult = _vnPayService.ValidateCallback(query);
            
            if (!vnPayResult.IsValidSignature)
                return (false, vnPayResult.Message);

            if (string.IsNullOrWhiteSpace(vnPayResult.OrderId) || !vnPayResult.OrderId.StartsWith("PAY_"))
                return (false, "Invalid order id");

            if (!int.TryParse(vnPayResult.OrderId.Replace("PAY_", ""), out var paymentId))
                return (false, "Invalid payment id");

            var payment = await _unitOfWork.PaymentRepository.GetByIdAsync(paymentId);
            if (payment == null) return (false, "Payment not found");
            if (payment.Status == PaymentStatus.Success) return (true, "Already processed");

            var booking = await _unitOfWork.BookingRepository.GetByIdWithDetailsAsync(payment.BookingId);
            if (booking == null) return (false, "Booking not found");

            if (vnPayResult.ResponseCode == "00" && vnPayResult.TransactionStatus == "00")
            {
                payment.Status = PaymentStatus.Success;
                payment.PaidAt = DateTime.UtcNow;
                
                // Lưu lại TransactionId của VNPay để sau này chủ tiệm có thể hoàn tiền (Refund)
                payment.TransactionId = vnPayResult.TransactionId; 
                _unitOfWork.PaymentRepository.Update(payment);

                string notificationTitle = "";
                string notificationMessage = "";

                if (payment.PaymentType == PaymentType.Deposit)
                {
                    if (booking.Status == BookingStatus.Pending)
                    {
                        booking.Status = BookingStatus.DepositPaid;
                    }
                    
                    notificationTitle = "💸 Cọc thành công";
                    notificationMessage = $"Bạn đã thanh toán tiền cọc thành công qua VNPay cho lịch hẹn #{booking.Id}. Cửa hàng sẽ sớm xếp thợ cho bạn!";
                }
                else if (payment.PaymentType == PaymentType.Full)
                {
                    if (booking.Status == BookingStatus.Pending || booking.Status == BookingStatus.DepositPaid)
                    {
                        booking.Status = BookingStatus.DepositPaid; 
                    }

                    notificationTitle = "✅ Thanh toán thành công";
                    notificationMessage = $"Bạn đã thanh toán toàn bộ chi phí qua VNPay cho lịch hẹn #{booking.Id}. Cửa hàng sẽ sớm xếp thợ cho bạn!";
                }

                _unitOfWork.BookingRepository.Update(booking);
                await _unitOfWork.SaveChangesAsync();
                 if (booking.CustomerId.HasValue)
    {
                await _notificationService.CreateAndSendNotificationAsync(
                    booking.CustomerId.Value,
                    notificationTitle,
                    notificationMessage,
                    NotificationType.BookingUpdate
                );

                return (true, "Confirm Success");
            }
            }
            payment.Status = PaymentStatus.Failed;
            _unitOfWork.PaymentRepository.Update(payment);
            await _unitOfWork.SaveChangesAsync();

            return (false, "Payment failed");
        }
    }
}