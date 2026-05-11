using BeautyBookingSystem.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.Booking
{
    public class BookingDetailDto
    {
        public int Id { get; set; }
        public DateTime CreatedAt { get; set; }

        public decimal TotalPrice { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal FinalPrice { get; set; }
        public decimal DepositAmount { get; set; }
        public decimal DepositPaidAmount { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal RemainingAmount { get; set; }
        public BookingStatus Status { get; set; }
        public string? CustomerNote { get; set; }
        public int StoreId { get; set; }
        public string StoreName { get; set; } = string.Empty;
        public string? CancelReason { get; set; }

        public List<BookingServiceDetailDto> Services { get; set; } = new();
        public List<PaymentDto> Payments { get; set; } = new();
    }

    public class BookingServiceDetailDto
    {
        public int Id { get; set; } 
        public int ServiceId { get; set; }
        public string ServiceName { get; set; } = string.Empty;
        public int? StaffId { get; set; }
        public string? StaffName { get; set; }
        public DateTime AppointmentDate { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
        public decimal Price { get; set; }

        public BookingDetailStatus Status { get; set; }
    }

    public class PaymentDto
    {
        public int Id { get; set; }
        public decimal Amount { get; set; }
        public PaymentMethod PaymentMethod { get; set; }
        public PaymentType PaymentType { get; set; }
        public PaymentStatus Status { get; set; }
        public DateTime? PaidAt { get; set; }
    }
}
