using BeautyBookingSystem.Domain.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Domain.Entities
{
    public class Review : BaseEntity
    {
        public int BookingId { get; set; }
        public virtual Booking Booking { get; set; } = null!;

        public int CustomerId { get; set; }
        public virtual User Customer { get; set; } = null!;

        public int StoreId { get; set; }
        public virtual Store Store { get; set; } = null!;

        public int Rating { get; set; } // Điểm 1 - 5
        public string? Comment { get; set; }
        public string? Reply { get; set; }
        public bool IsHidden { get; set; }
    }
}
