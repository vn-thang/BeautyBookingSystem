using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.MyStore
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
        public decimal AverageRating { get; set; } 
        public int TotalReviews { get; set; }
        public int DepositPercent { get; set; }
        public decimal DepositThreshold { get; set; }
        public string? BankName { get; set; } 
        public string? BankAccountNumber { get; set; }
        public string? BankAccountName { get; set; }

        public List<OperatingHourDto> OperatingHours { get; set; } = new();
    }
}
