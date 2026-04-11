using BeautyBookingSystem.Domain.Enums;

namespace BeautyBookingSystem.Application.DTOs.Payments
{
    public class CreatePaymentRequest
    {
        public int BookingId { get; set; }
        public int Amount { get; set; }
        public string OrderInfo { get; set; } = default!;
        public PaymentMethod PaymentMethod { get; set; }
    }
}