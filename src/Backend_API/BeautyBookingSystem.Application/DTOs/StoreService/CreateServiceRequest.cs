using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.StoreService
{
    public class CreateServiceRequest
    {
        [Required(ErrorMessage = "Vui lòng chọn danh mục hệ thống")]
        public int CategoryId { get; set; }

        public int? GroupId { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập tên dịch vụ")]
        public string Name { get; set; } = string.Empty;

        public string? Description { get; set; }
        public string? ImageUrl { get; set; }

        [Range(0, double.MaxValue, ErrorMessage = "Giá tiền không hợp lệ")]
        public decimal Price { get; set; }

        [Range(1, 1440, ErrorMessage = "Thời gian thực hiện phải từ 1 phút trở lên")]
        public int DurationMinutes { get; set; }

        public bool IsFeatured { get; set; } = false;
        public int SortOrder { get; set; } = 0;
    }
}
