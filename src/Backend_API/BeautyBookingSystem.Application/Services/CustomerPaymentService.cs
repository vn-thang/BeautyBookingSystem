using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.DTOs.Payments;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
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

            var expireTime = DateTime.UtcNow.AddMinutes(-15);
            
            var activePayment = booking.Payments.FirstOrDefault(p => 
                p.PaymentMethod == req.PaymentMethod && 
                p.Status == PaymentStatus.Pending && 
                p.Amount == req.Amount &&              
                p.CreatedAt > expireTime);             

            if (activePayment == null)
            {
                activePayment = new Payment
                {
                    BookingId = booking.Id,
                    Amount = req.Amount,
                    PaymentMethod = req.PaymentMethod,
                    PaymentType = paymentType,
                    Status = PaymentStatus.Pending,
                    CreatedAt = DateTime.UtcNow 
                };
                
                await _unitOfWork.PaymentRepository.AddAsync(activePayment);
                await _unitOfWork.SaveChangesAsync(); 
            }

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
        payment.TransactionId = vnPayResult.TransactionId; 
        _unitOfWork.PaymentRepository.Update(payment);

        var duplicatePendingPayments = booking.Payments
            .Where(p => p.Status == PaymentStatus.Pending 
                     && p.Id != payment.Id 
                     && p.PaymentType == payment.PaymentType)
            .ToList();

        foreach (var dupPayment in duplicatePendingPayments)
        {
            dupPayment.Status = PaymentStatus.Failed;
            _unitOfWork.PaymentRepository.Update(dupPayment);
        }

        string notificationTitle = "";
        string notificationMessage = "";

        if (payment.PaymentType == PaymentType.Deposit)
        {
            if (booking.Status == BookingStatus.Pending)
                booking.Status = BookingStatus.DepositPaid;
                
            notificationTitle = "💸 Cọc thành công";
            notificationMessage = $"Bạn đã thanh toán tiền cọc thành công qua VNPay cho lịch hẹn #{booking.Id}. Cửa hàng sẽ sớm xếp thợ cho bạn!";
        }
        else if (payment.PaymentType == PaymentType.Full || payment.PaymentType == PaymentType.Remaining)
        {
            if (booking.Status == BookingStatus.Pending || booking.Status == BookingStatus.DepositPaid)
                booking.Status = BookingStatus.DepositPaid; 

            notificationTitle = "✅ Thanh toán thành công";
            notificationMessage = $"Bạn đã thanh toán chi phí qua VNPay cho lịch hẹn #{booking.Id}. Cửa hàng sẽ sớm xếp thợ cho bạn!";
        }

        _unitOfWork.BookingRepository.Update(booking);

        var store = await _unitOfWork.StoreRepository.GetByIdAsync(booking.StoreId);
        if (store != null)
        {
            decimal balanceBefore = store.WalletBalance;
            store.WalletBalance += payment.Amount;
            _unitOfWork.StoreRepository.Update(store);
            string transactionDescription = payment.PaymentType == PaymentType.Deposit 
            ? $"Cộng tiền cọc cho đơn hàng #{booking.Id}" 
            : $"Cộng tiền thanh toán cho đơn hàng #{booking.Id}";
            var walletTransaction = new WalletTransaction
            {
                StoreId = store.Id,
                Type = TransactionType.TopUp, 
                Amount = payment.Amount,
                BalanceBefore = balanceBefore,
                BalanceAfter = store.WalletBalance,
                Status = TransactionStatus.Completed,
                Description = transactionDescription,
                CreatedAt = DateTime.UtcNow
            };
            await _unitOfWork.WalletTransactionRepository.AddAsync(walletTransaction);
        }

        await _unitOfWork.SaveChangesAsync();

        try 
        {
            if (booking.CustomerId.HasValue)
            {
                await _notificationService.CreateAndSendNotificationAsync(
                    booking.CustomerId.Value, notificationTitle, notificationMessage, NotificationType.BookingUpdate
                );
            }

            if (store != null)
            {
              string description = payment.PaymentType == PaymentType.Deposit 
            ? $"Nhận tiền cọc đơn hàng #{booking.Id}" 
            : $"Nhận tiền thanh toán đơn hàng #{booking.Id}";
                await _notificationService.CreateAndSendNotificationAsync(
                    store.OwnerId,
                    "💰 Nhận tiền thành công",
                    $"Khách hàng vừa thanh toán {payment.Amount:N0}đ ({description}) qua VNPay cho lịch hẹn #{booking.Id}. Số tiền đã được cộng vào ví của bạn.",
                    NotificationType.SystemAlert 
                );
            }
        }
        catch (Exception ex)
        {
        }

        return (true, "Confirm Success");
    }
            
    payment.Status = PaymentStatus.Failed;
    _unitOfWork.PaymentRepository.Update(payment);
    await _unitOfWork.SaveChangesAsync();

    return (false, "Payment failed");
}


    public async Task<bool> RefundPaymentAsync(int paymentId, int storeId, string cancelBy = "System")
    {
        var payment = await _unitOfWork.PaymentRepository.GetQueryable()
            .Include(p => p.Booking)
            .FirstOrDefaultAsync(p => p.Id == paymentId && p.Booking.StoreId == storeId);

        if (payment == null) throw new NotFoundException("Không tìm thấy giao dịch này.");
        if (payment.Status != PaymentStatus.Success) throw new Exception("Giao dịch chưa thành công, không thể hoàn tiền.");

        if (string.IsNullOrEmpty(payment.VnpPayDate) || string.IsNullOrEmpty(payment.TransactionId))
            throw new Exception("Thiếu thông tin giao dịch gốc từ VNPay. Không thể tự động hoàn tiền.");

        var refundResult = await _vnPayService.RefundAsync(
            vnp_TxnRef: payment.TransactionId,
            vnp_TransactionDate: payment.VnpPayDate,
            amount: payment.Amount,
            createBy: cancelBy, 
            vnp_TransactionNo: payment.VnpTransactionNo ?? ""
        );

        if (!refundResult.IsSuccess)
            throw new Exception($"VNPay từ chối hoàn tiền: {refundResult.Message}");

        payment.Status = PaymentStatus.Refunded;
        _unitOfWork.PaymentRepository.Update(payment);

        var store = await _unitOfWork.StoreRepository.GetByIdAsync(payment.Booking.StoreId);
        if (store != null)
        {
            decimal balanceBefore = store.WalletBalance;
            store.WalletBalance -= payment.Amount;
            _unitOfWork.StoreRepository.Update(store);
            
            var walletTx = new WalletTransaction
            {
                StoreId = store.Id,
                Type = TransactionType.Withdrawal, 
                Amount = payment.Amount,
                BalanceBefore = balanceBefore,
                BalanceAfter = store.WalletBalance,
                Status = TransactionStatus.Completed,
                Description = $"Hệ thống trừ tiền do hoàn thanh toán đơn #{payment.BookingId}",
                CreatedAt = DateTime.UtcNow
            };
            await _unitOfWork.WalletTransactionRepository.AddAsync(walletTx);
        }

        var result = await _unitOfWork.SaveChangesAsync() > 0;

        if (result && payment.Booking.CustomerId.HasValue)
        {
            await _notificationService.CreateAndSendNotificationAsync(
                payment.Booking.CustomerId.Value,
                "🔄 Thông báo hoàn tiền",
                $"Số tiền {payment.Amount:N0}đ của lịch hẹn #{payment.BookingId} đã được hoàn lại qua VNPay.",
                NotificationType.SystemAlert
            );
        }

        return result;
    }
    }
}