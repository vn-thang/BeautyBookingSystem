using BeautyBookingSystem.Domain.Enums;
using System;

namespace BeautyBookingSystem.Application.DTOs.AdminBooking
{
    public class AdminBookingListDto
    {
        public int Id { get; set; }
        public string CustomerName { get; set; } = null!;
        public string CustomerPhone { get; set; } = null!;
        public string StoreName { get; set; } = null!;
        public decimal FinalPrice { get; set; }
        public BookingStatus Status { get; set; }
        public PaymentStatus PaymentStatus { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}