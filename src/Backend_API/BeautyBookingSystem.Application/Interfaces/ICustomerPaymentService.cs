using BeautyBookingSystem.Application.DTOs.Payments;
using Microsoft.AspNetCore.Http;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface ICustomerPaymentService
    {
        Task<PaymentCreationResult> CreatePaymentAsync(CreatePaymentRequest req, string ipAddress);
        Task<(bool Success, string Message)> ProcessVnpayCallbackAsync(IQueryCollection query);
    }
}