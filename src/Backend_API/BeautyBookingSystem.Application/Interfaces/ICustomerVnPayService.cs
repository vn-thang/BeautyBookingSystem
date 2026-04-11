using BeautyBookingSystem.Application.DTOs.Payments;
using BeautyBookingSystem.Domain.Entities;
using Microsoft.AspNetCore.Http;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface ICustomerVnPayService
    {
        string CreatePaymentUrl(Payment payment, CreatePaymentRequest req, string ipAddress);
        VnPayCallbackResult ValidateCallback(IQueryCollection query);
    }
}