using BeautyBookingSystem.Application.DTOs.StoreCustomer;
namespace BeautyBookingSystem.Application.DTOs.StoreCustomer
{
public class CustomerProfileDto : CustomerListDto
    {
        public int TotalCancelled { get; set; } // Tổng số lần bom/hủy lịch
        public List<CustomerServiceHistoryDto> ServiceHistories { get; set; } = new();
    }
}