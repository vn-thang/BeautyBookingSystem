
namespace BeautyBookingSystem.Application.DTOs.StoreStatistics
{
public class ReviewStatisticsDto
    {
        public double AverageRating { get; set; } = 0;
        public int TotalReviews { get; set; } = 0;
        public int FiveStarCount { get; set; } = 0;
        public int FourStarCount { get; set; } = 0;
        public int ThreeStarCount { get; set; } = 0;
        public int TwoStarCount { get; set; } = 0;
        public int OneStarCount { get; set; } = 0;
    }
}