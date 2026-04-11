
namespace BeautyBookingSystem.Application.DTOs.CustomerStore
{
     public class StoreDetailDto
    {
        public int Id { get; set; }

        public string Name { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string? Phone { get; set; }
        public string? Description { get; set; }
        public string? ZaloPhone { get; set; }
        public string? FacebookUrl { get; set; }

        public string? LogoUrl { get; set; }
        public string? CoverImageUrl { get; set; }

        public double? Latitude { get; set; }
        public double? Longitude { get; set; }

        public bool IsOpen { get; set; }

        public decimal AverageRating { get; set; }
        public int TotalReviews { get; set; }
        public int DepositPercent { get; set; }
        public decimal DepositThreshold { get; set; }
        public bool IsFavorite { get; set; }


        public List<StoreBannerDto> Banners { get; set; } = new();
        public List<ServiceItemDto> Services { get; set; } = new();
        public List<OperatingHourViewDto> OperatingHours { get; set; } = new();
    }

    public class StoreBannerDto
    {
        public int Id { get; set; }
        public string ImageUrl { get; set; } = string.Empty;
        public string? Title { get; set; }
        public string? Description { get; set; }
        public int SortOrder { get; set; }
    }

    public class OperatingHourViewDto
    {
        public int DayOfWeek { get; set; }
        public string OpenTime { get; set; } = string.Empty;
        public string CloseTime { get; set; } = string.Empty;
    }
}
