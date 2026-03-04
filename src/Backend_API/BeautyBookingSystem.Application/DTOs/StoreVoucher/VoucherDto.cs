using BeautyBookingSystem.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.StoreVoucher
{
    public class VoucherDto
    {
        public int Id { get; set; }
        public string Code { get; set; } = string.Empty;
        public int? ServiceId { get; set; }
        public string? ServiceName { get; set; }
        public DiscountType DiscountType { get; set; }
        public decimal DiscountValue { get; set; }
        public decimal MinOrderValue { get; set; }
        public decimal MaxDiscount { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int UsageLimit { get; set; }
        public int UsedCount { get; set; }

        public string Status
        {
            get
            {
                var now = DateTime.UtcNow;
                if (now < StartDate) return "Sắp diễn ra";
                if (now > EndDate || UsedCount >= UsageLimit) return "Đã kết thúc";
                return "Đang diễn ra";
            }
        }
    }
}
