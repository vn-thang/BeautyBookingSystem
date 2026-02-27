using BeautyBookingSystem.Domain.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BeautyBookingSystem.Domain.Enums;

namespace BeautyBookingSystem.Domain.Entities
{
    public class Payment : BaseEntity
    {
        public int BookingId { get; set; }
        public virtual Booking Booking { get; set; } = null!;

        public PaymentMethod PaymentMethod { get; set; }
        public PaymentType PaymentType { get; set; }
        public decimal Amount { get; set; }
        public PaymentStatus Status { get; set; }
        public string? TransactionId { get; set; }
        public DateTime? PaidAt { get; set; }
    }
}
