using BeautyBookingSystem.Application.DTOs.StoreCustomer;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IStoreCustomerService
    {
        // Lấy danh sách khách hàng của tiệm (có hỗ trợ tìm kiếm)
        Task<List<CustomerListDto>> GetStoreCustomersAsync(int storeId, string? searchTerm = null);
        
        // Lấy chi tiết hồ sơ 1 khách hàng (Hồ sơ 360 độ)
        Task<CustomerProfileDto?> GetCustomerProfileAsync(int storeId, int customerId);
    }
}