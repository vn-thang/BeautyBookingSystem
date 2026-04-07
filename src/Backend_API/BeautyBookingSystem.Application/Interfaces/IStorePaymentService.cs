using BeautyBookingSystem.Application.DTOs.StorePayment;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IStorePaymentService
    {
        Task<List<StorePaymentListDto>> GetPaymentsAsync(PaymentFilterRequest request);
        Task<bool> ConfirmPaymentAsync(int paymentId, ConfirmPaymentRequest request);
        Task<bool> RefundPaymentAsync(int paymentId);
    }
}
