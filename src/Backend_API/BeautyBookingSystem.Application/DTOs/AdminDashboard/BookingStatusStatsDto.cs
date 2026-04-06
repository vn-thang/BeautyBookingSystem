using System;

namespace BeautyBookingSystem.Application.DTOs.AdminDashboard
{
    public class BookingStatusStatsDto
    {
        public string Status { get; set; } = string.Empty;
        public int Count { get; set; }
    }
}