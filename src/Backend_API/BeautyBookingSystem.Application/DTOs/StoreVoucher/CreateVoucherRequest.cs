using BeautyBookingSystem.Domain.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.StoreVoucher
{
    public class CreateVoucherRequest
    {
        [Required(ErrorMessage = "Mã khuyến mãi không được để trống")]
        [StringLength(50, ErrorMessage = "Mã khuyến mãi không vượt quá 50 ký tự")]
        public string Code { get; set; } = string.Empty;
        public int? ServiceId { get; set; }
        public DiscountType DiscountType { get; set; }

        [Range(1, double.MaxValue, ErrorMessage = "Giá trị giảm phải lớn hơn 0")]
        public decimal DiscountValue { get; set; }

        public decimal MinOrderValue { get; set; }
        public decimal MaxDiscount { get; set; }

        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Giới hạn sử dụng phải ít nhất là 1")]
        public int UsageLimit { get; set; }
    }
}
