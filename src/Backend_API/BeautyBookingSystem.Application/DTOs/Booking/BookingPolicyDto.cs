
namespace BeautyBookingSystem.Application.DTOs.Booking
{
    public class BookingPolicyDto
    {
        public int BookingMinHours { get; set; }
        public int CancelBeforeHours { get; set; }
        public int GracePeriodMinutes { get; set; }
        public int MaxCancelPerDay { get; set; }
        public int NoShowLimit { get; set; }
        public bool BlockUserIfNoShow { get; set; }
        public int RescheduleBeforeHours { get; set; }

        public bool IsBookingBlocked { get; set; }
        public int CurrentNoShowCount { get; set; }
        public int CurrentCancelCountToday { get; set; }
        public string? BlockReason { get; set; }
    }
}