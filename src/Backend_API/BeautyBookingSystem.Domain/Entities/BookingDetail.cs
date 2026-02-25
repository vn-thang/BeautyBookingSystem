using BeautyBookingSystem.Domain.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BeautyBookingSystem.Domain.Enums;
namespace BeautyBookingSystem.Domain.Entities
{
    public class BookingDetail : BaseEntity
    {
        public int BookingId { get; set; }
        public virtual Booking Booking { get; set; } = null!;

        public int ServiceId { get; set; }
        public virtual Service Service { get; set; } = null!;

        public int? StaffId { get; set; }
        public virtual Staff? Staff { get; set; }

        public DateTime AppointmentDate { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
        public decimal Price { get; set; }

        public BookingDetailStatus Status { get; set; }
    }
}
