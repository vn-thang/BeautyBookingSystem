namespace BeautyBookingSystem.Application.DTOs.StoreWallet
{
    public class VnPayResponseDto
    {
        public bool Success { get; set; }
        public string OrderDescription { get; set; } = string.Empty;
        public string TransactionId { get; set; } = string.Empty;

        public string OrderId { get; set; } = string.Empty;

        public string PaymentMethod { get; set; } = string.Empty;

        public string VnPayResponseCode { get; set; } = string.Empty;
        public decimal Amount { get; set; }

    }
}