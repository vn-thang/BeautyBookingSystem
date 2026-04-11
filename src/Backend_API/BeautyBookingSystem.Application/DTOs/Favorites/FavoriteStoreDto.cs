namespace BeautyBookingSystem.Application.DTOs
{
    public class FavoriteStoreDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Address { get; set; }
        public string? LogoUrl { get; set; }
        public string? CoverImageUrl { get; set; }
        public double? AverageRating { get; set; }
        public int? TotalReviews { get; set; }
        public double? DistanceKm { get; set; }
    }
}