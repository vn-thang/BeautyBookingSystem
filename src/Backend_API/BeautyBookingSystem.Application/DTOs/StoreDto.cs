namespace BeautyBookingSystem.Application.DTOs
{
    public class StoreDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string Phone { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? LogoUrl { get; set; }
        public string? CoverImageUrl { get; set; }

        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public bool IsOpen { get; set; }
    }
}