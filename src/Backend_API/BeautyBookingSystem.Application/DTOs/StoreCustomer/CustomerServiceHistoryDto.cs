namespace BeautyBookingSystem.Application.DTOs.StoreCustomer
{
public class CustomerServiceHistoryDto
    {
        public int BookingId { get; set; }
        public DateTime AppointmentDate { get; set; }
        public TimeSpan StartTime { get; set; }
        public string ServiceName { get; set; } = string.Empty;
        public string StaffName { get; set; } = string.Empty;
        public decimal Price { get; set; } // Giá của dịch vụ đó lúc khách làm
    }
}