using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.Booking
{
    public class BookingTimeSlotDto
    {
        public string Time { get; set; } = string.Empty;
        public bool IsAvailable { get; set; }
    }
}
