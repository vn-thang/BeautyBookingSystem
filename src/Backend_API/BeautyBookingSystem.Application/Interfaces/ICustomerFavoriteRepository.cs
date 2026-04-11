using BeautyBookingSystem.Application.DTOs;
using BeautyBookingSystem.Domain.Entities;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface ICustomerFavoriteRepository
    {
        Task<CustomerFavorite?> GetStoreFavoriteAsync(int customerId, int storeId);
        Task<CustomerFavorite?> GetServiceFavoriteAsync(int customerId, int serviceId);
        Task AddAsync(CustomerFavorite favorite);
        void Remove(CustomerFavorite favorite);
        Task<int> SaveChangesAsync();
        Task<bool> IsStoreFavoriteAsync(int customerId, int storeId);
        Task<bool> IsServiceFavoriteAsync(int customerId, int serviceId);
        Task<List<FavoriteStoreDto>> GetFavoriteStoresAsync(
            int customerId,
            double? latitude,
            double? longitude);
        Task<List<FavoriteServiceDto>> GetFavoriteServicesAsync(int customerId);
    }
}