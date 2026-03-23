using BeautyBookingSystem.Domain.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BeautyBookingSystem.Domain.Enums;

namespace BeautyBookingSystem.Domain.Entities
{
    public class Voucher : BaseEntity
    {
        public int StoreId { get; set; }
        public virtual Store Store { get; set; } = null!;

        public string Code { get; set; } = string.Empty;
        public DiscountType DiscountType { get; set; }
        public decimal DiscountValue { get; set; }
        public decimal MinOrderValue { get; set; }
        public decimal MaxDiscount { get; set; }

        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int UsageLimit { get; set; }
        public int UsedCount { get; set; }
        public string? ImageUrl { get; set; }

        public int? ServiceId { get; set; }
        public virtual Service? Service { get; set; }

        public virtual ICollection<UserVoucher> UserVouchers { get; set; } = new List<UserVoucher>();
        public virtual ICollection<Booking> Bookings { get; set; } = new List<Booking>();
    }
}
