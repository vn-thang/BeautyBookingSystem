using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.Store
{
    public class StoreProfileDto
    {
        [Required(ErrorMessage = "Tên cửa hàng là bắt buộc")]
        [StringLength(100, ErrorMessage = "Tên không được vượt quá 100 ký tự")]
        public string Name { get; set; } = null!;

        [Required(ErrorMessage = "Địa chỉ không được để trống")]
        public string Address { get; set; } = null!;

        [Required(ErrorMessage = "Số điện thoại là bắt buộc")]
        [Phone(ErrorMessage = "Số điện thoại không đúng định dạng")]
        public string Phone { get; set; } = null!;

        public string? Description { get; set; }

        public string? LogoUrl { get; set; }

        public string? CoverImageUrl { get; set; }

        public double? Latitude { get; set; }
        public double? Longitude { get; set; }

        public bool IsOpen { get; set; }

        public List<OperatingHourDto> OperatingHours { get; set; } = new();
    }

    public class OperatingHourDto
    {
        [Required]
        [Range(0, 6, ErrorMessage = "Thứ phải từ 0 (Chủ nhật) đến 6 (Thứ bảy)")]
        public DayOfWeek DayOfWeek { get; set; }

        [Required(ErrorMessage = "Giờ mở cửa không được để trống")]
        [RegularExpression(@"^([01]\d|2[0-3]):([0-5]\d)$", ErrorMessage = "Giờ mở cửa phải có định dạng HH:mm (VD: 08:00)")]
        public string OpenTime { get; set; } = null!;

        [Required(ErrorMessage = "Giờ đóng cửa không được để trống")]
        [RegularExpression(@"^([01]\d|2[0-3]):([0-5]\d)$", ErrorMessage = "Giờ đóng cửa phải có định dạng HH:mm (VD: 20:00)")]
        public string CloseTime { get; set; } = null!;
    }
}
