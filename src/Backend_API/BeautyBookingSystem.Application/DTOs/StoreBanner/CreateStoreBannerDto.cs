using System.ComponentModel.DataAnnotations;

namespace BeautyBookingSystem.Application.DTOs.StoreBanner
{
    public class CreateStoreBannerDto
    {
        [Required]
        public string ImageUrl { get; set; } = string.Empty;
        public string? Title { get; set; }
        public string? Description { get; set; }
        public int SortOrder { get; set; }
    }
}