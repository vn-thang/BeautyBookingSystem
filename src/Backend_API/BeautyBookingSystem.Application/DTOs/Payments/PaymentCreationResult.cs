
namespace BeautyBookingSystem.Application.DTOs.Payments
{
public class PaymentCreationResult
    {
        public string Url { get; set; } = default!;
        public int PaymentId { get; set; }
        public int BookingId { get; set; }
        public decimal Amount { get; set; }
    }
}