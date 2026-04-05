using BeautyBookingSystem.Application.DTOs.User;

namespace BeautyBookingSystem.Application.DTOs.Reviews
{
    public class StoreReviewResponseDto
    {
        public int Id { get; set; }
        public int BookingId { get; set; }
        public int CustomerId { get; set; }
        public int StoreId { get; set; }
        public string StoreName { get; set; } = string.Empty;
        public UserProfileResponse Customer { get; set; } = new();
        public int Rating { get; set; }
        public string? Comment { get; set; }
        public string? Reply { get; set; }
        public bool IsHidden { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}