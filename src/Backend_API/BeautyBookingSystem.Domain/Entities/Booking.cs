using BeautyBookingSystem.Domain.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BeautyBookingSystem.Domain.Enums; 

namespace BeautyBookingSystem.Domain.Entities
{
    public class Booking : BaseEntity
    {
        public int CustomerId { get; set; }
        public virtual User Customer { get; set; } = null!;

        public int StoreId { get; set; }
        public virtual Store Store { get; set; } = null!;

        public int? VoucherId { get; set; }
        public virtual Voucher? Voucher { get; set; }

        public decimal TotalPrice { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal FinalPrice { get; set; }

        public BookingStatus Status { get; set; }
        public string? CustomerNote { get; set; }
        public CancelledByType? CancelledBy { get; set; }
        public string? CancelReason { get; set; }

        public virtual ICollection<BookingDetail> BookingDetails { get; set; } = new List<BookingDetail>();
        public virtual ICollection<Payment> Payments { get; set; } = new List<Payment>();
        public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();
    }
}
