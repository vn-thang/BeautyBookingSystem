using System.ComponentModel.DataAnnotations;

namespace BeautyBookingSystem.Application.DTOs.SystemConfig
{
    public class UpdateSystemConfigRequest
    {
        [Required(ErrorMessage = "Giá trị là bắt buộc.")]
        public string Value { get; set; } = null!;
    }
}