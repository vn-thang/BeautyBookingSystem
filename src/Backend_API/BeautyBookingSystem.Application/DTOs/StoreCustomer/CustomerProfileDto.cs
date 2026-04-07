using BeautyBookingSystem.Application.DTOs.StoreCustomer;
namespace BeautyBookingSystem.Application.DTOs.StoreCustomer
{
public class CustomerProfileDto : CustomerListDto
    {
        public int TotalCancelled { get; set; }
        public List<CustomerServiceHistoryDto> ServiceHistories { get; set; } = new();
    }
}