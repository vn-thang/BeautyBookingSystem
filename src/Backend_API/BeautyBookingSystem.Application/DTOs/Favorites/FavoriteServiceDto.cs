namespace BeautyBookingSystem.Application.DTOs
{
    public class FavoriteServiceDto
    {
        public int Id { get; set; }
        public int StoreId { get; set; }
        public string? StoreName { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? ImageUrl { get; set; }
        public decimal? Price { get; set; }
        public int? DurationMinutes { get; set; }
    }
}