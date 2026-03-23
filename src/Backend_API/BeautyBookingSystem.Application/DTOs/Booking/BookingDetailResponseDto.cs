using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.Booking
{
    public class BookingDetailResponseDto
    {
        public int ServiceId { get; set; }

        public string ServiceName { get; set; } = "";

        public int? StaffId { get; set; }

        public DateTime AppointmentDate { get; set; }

        public TimeSpan StartTime { get; set; }

        public TimeSpan EndTime { get; set; }

        public decimal Price { get; set; }
    }
}
