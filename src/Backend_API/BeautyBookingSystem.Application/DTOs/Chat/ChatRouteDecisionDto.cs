namespace BeautyBookingSystem.Application.DTOs.Chat
{
    public sealed class ChatRouteDecisionDto
    {
        public string Intent { get; set; } = "unknown";
        public string? Keyword { get; set; }
        public string? SortBy { get; set; }
        public decimal? MinPrice { get; set; }
        public decimal? MaxPrice { get; set; }
        public int? StoreId { get; set; }
        public int? ServiceId { get; set; }
        public bool NeedsLocation { get; set; }
        public string? ClarifyingQuestion { get; set; }
    }
}