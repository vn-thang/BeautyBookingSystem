using BeautyBookingSystem.Domain.Enums;

namespace BeautyBookingSystem.Application.DTOs.Booking
{
    public class BookingListItemDto
    {
        public int Id { get; set; }
        public DateTime CreatedAt { get; set; }

        public DateTime AppointmentDateTime { get; set; }
        public int StoreId { get; set; }
        public string StoreName { get; set; } = string.Empty;
        public string? StoreAvatarUrl { get; set; }

        public string MainServiceName { get; set; } = string.Empty;
        public int ExtraServiceCount { get; set; }
        public string ServiceSummary { get; set; } = string.Empty;

        public string? StaffName { get; set; }
        public string? StaffAvatarUrl { get; set; }

        public decimal TotalPrice { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal DepositAmount { get; set; }
        public decimal FinalPrice { get; set; }
        public decimal PaidAmount { get; set; }
        public decimal RemainingAmount { get; set; }
        public string? CancelReason { get; set; }

        public BookingStatus Status { get; set; }
    }
}