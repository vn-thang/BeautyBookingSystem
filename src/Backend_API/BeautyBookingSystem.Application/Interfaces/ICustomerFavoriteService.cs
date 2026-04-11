using BeautyBookingSystem.Application.DTOs;
using BeautyBookingSystem.Domain.Entities;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface ICustomerFavoriteService
    {
        Task FavoriteStoreAsync(int customerId, int storeId);
        Task UnfavoriteStoreAsync(int customerId, int storeId);

        Task FavoriteServiceAsync(int customerId, int serviceId);
        Task UnfavoriteServiceAsync(int customerId, int serviceId);

        Task<List<FavoriteStoreDto>> GetFavoriteStoresAsync(
            int customerId,
            double? latitude,
            double? longitude);
        Task<List<FavoriteServiceDto>> GetFavoriteServicesAsync(int customerId);
    }
}