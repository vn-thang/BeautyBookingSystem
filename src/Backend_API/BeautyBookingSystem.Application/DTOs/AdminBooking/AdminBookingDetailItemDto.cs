using BeautyBookingSystem.Domain.Enums;
using System;
using System.Collections.Generic;

namespace BeautyBookingSystem.Application.DTOs.AdminBooking
{
public class AdminBookingDetailItemDto
    {
        public int BookingDetailId { get; set; }
        public string ServiceName { get; set; } = null!;
        public string? StaffName { get; set; }
        public DateTime AppointmentDate { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
        public decimal Price { get; set; }
        public BookingDetailStatus Status { get; set; }
    }
}