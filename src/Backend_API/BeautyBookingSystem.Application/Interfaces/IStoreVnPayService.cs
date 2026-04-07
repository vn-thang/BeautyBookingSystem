using BeautyBookingSystem.Application.DTOs.StoreWallet; 
using Microsoft.AspNetCore.Http;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IStoreVnPayService
    {
       string CreatePaymentUrl(TopUpRequest model); 
        VnPayResponseDto PaymentExecute();
        Task<bool> RefundAsync(string vnp_TxnRef, string vnp_TransactionDate, decimal amount, string createBy);
    }
}