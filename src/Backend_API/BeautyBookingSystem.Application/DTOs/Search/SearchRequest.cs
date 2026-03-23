namespace BeautyBookingSystem.Application.DTOs.Search
{
    public class SearchRequest
    {
        public string? Keyword { get; set; }

        public string? Location { get; set; }

        public double? UserLat { get; set; }

        public double? UserLng { get; set; }

        public string SortBy { get; set; } = "nearest";

        public int? MinRating { get; set; }

        public decimal? MinPrice { get; set; }

        public decimal? MaxPrice { get; set; }
    }
}