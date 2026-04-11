namespace BeautyBookingSystem.Application.DTOs.Booking
{
    public class RescheduleBookingRequest
    {
        public DateTime NewAppointmentDate { get; set; }
        public TimeSpan NewStartTime { get; set; }
        public int? NewStaffId { get; set; } 
        public string? Reason { get; set; }
    }
}