using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.StoreBooking
{
    public class BookingServiceItemDto
    {
        public int BookingDetailId { get; set; }
        public string ServiceName { get; set; } = string.Empty;
        public DateTime AppointmentDate { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
        public decimal Price { get; set; }
        public int? StaffId { get; set; }
        public string? StaffName { get; set; }
        public string DetailStatus { get; set; } = string.Empty;
    }
}
