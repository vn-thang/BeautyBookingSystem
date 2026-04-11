
namespace BeautyBookingSystem.Application.DTOs.Payments
{
public class VnPayCallbackResult
    {
        public bool IsValidSignature { get; set; }
        public string ResponseCode { get; set; } = string.Empty;
        public string TransactionStatus { get; set; } = string.Empty;
        public string OrderId { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public string? TransactionId { get; set; }
    }
}