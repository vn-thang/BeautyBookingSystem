using BeautyBookingSystem.Application.DTOs.Payments;
using BeautyBookingSystem.Domain.Entities;
using Microsoft.AspNetCore.Http;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface ICustomerVnPayService
    {
        string CreatePaymentUrl(Payment payment, CreatePaymentRequest req, string ipAddress);
        VnPayCallbackResult ValidateCallback(IQueryCollection query);
          Task<(bool IsSuccess, string ResponseCode, string Message)> RefundAsync(
            string vnp_TxnRef, 
            string vnp_TransactionDate, 
            decimal amount, 
            string createBy, 
            string vnp_TransactionNo = "");
    }
}