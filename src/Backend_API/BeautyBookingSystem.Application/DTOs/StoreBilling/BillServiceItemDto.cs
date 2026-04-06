namespace BeautyBookingSystem.Application.DTOs.StoreBilling;
public class BillServiceItemDto
    {
        public string ServiceName { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal TotalPrice { get; set; }
    }