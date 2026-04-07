namespace BeautyBookingSystem.Application.DTOs.Reviews
{
    public class CreateReviewRequestDto
    {
        public int BookingId { get; set; }
        public int Rating { get; set; } // 1 - 5
        public string? Comment { get; set; }
    }
}