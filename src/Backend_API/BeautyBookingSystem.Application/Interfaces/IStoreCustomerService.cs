using BeautyBookingSystem.Application.DTOs.StoreCustomer;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IStoreCustomerService
    {
        Task<List<CustomerListDto>> GetStoreCustomersAsync(int storeId, string? searchTerm = null);
        Task<CustomerProfileDto?> GetCustomerProfileAsync(int storeId, int customerId);
    }
}