namespace BeautyBookingSystem.Application.DTOs.Search
{
    public class SearchStoreResponse
    {
        public int Id { get; set; }

        public string Name { get; set; } = string.Empty;

        public string Address { get; set; } = string.Empty;

        public string? ImageUrl { get; set; }

        public decimal Rating { get; set; }

        public double DistanceKm { get; set; }

        public double? Lat { get; set; }

        public double? Lng { get; set; }

        public decimal MinServicePrice { get; set; }

        public List<SearchServiceResponse> Services { get; set; } = new();
    }
}