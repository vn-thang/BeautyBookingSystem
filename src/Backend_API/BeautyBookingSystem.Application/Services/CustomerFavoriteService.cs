using BeautyBookingSystem.Application.DTOs;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;

namespace BeautyBookingSystem.Application.Services
{
    public class CustomerFavoriteService : ICustomerFavoriteService
    {
        private readonly ICustomerFavoriteRepository _favoriteRepository;
        private readonly IStoreRepository _storeRepository;
        private readonly IServiceRepository _serviceRepository;

        public CustomerFavoriteService(
            ICustomerFavoriteRepository favoriteRepository,
            IStoreRepository storeRepository,
            IServiceRepository serviceRepository)
        {
            _favoriteRepository = favoriteRepository;
            _storeRepository = storeRepository;
            _serviceRepository = serviceRepository;
        }

        public async Task<List<FavoriteStoreDto>> GetFavoriteStoresAsync(
            int customerId,
            double? latitude,
            double? longitude)
        {
            return await _favoriteRepository.GetFavoriteStoresAsync(customerId, latitude, longitude);
        }

        public async Task<List<FavoriteServiceDto>> GetFavoriteServicesAsync(int customerId)
        {
            return await _favoriteRepository.GetFavoriteServicesAsync(customerId);
        }

        public async Task FavoriteStoreAsync(int customerId, int storeId)
        {
            var store = await _storeRepository.GetByIdAsync(storeId);
            if (store == null)
                throw new InvalidOperationException("Store không tồn tại.");

            var existed = await _favoriteRepository.GetStoreFavoriteAsync(customerId, storeId);
            if (existed != null)
                return;

            var favorite = new CustomerFavorite
            {
                CustomerId = customerId,
                StoreId = storeId,
                ServiceId = null
            };

            await _favoriteRepository.AddAsync(favorite);
            await _favoriteRepository.SaveChangesAsync();
        }

        public async Task UnfavoriteStoreAsync(int customerId, int storeId)
        {
            var existed = await _favoriteRepository.GetStoreFavoriteAsync(customerId, storeId);
            if (existed == null)
                return;

            _favoriteRepository.Remove(existed);
            await _favoriteRepository.SaveChangesAsync();
        }

        public async Task FavoriteServiceAsync(int customerId, int serviceId)
        {
            var service = await _serviceRepository.GetByIdAsync(serviceId);
            if (service == null)
                throw new InvalidOperationException("Service không tồn tại.");

            if (service.StoreId <= 0)
                throw new InvalidOperationException("Service chưa gắn với store hợp lệ.");

            var existed = await _favoriteRepository.GetServiceFavoriteAsync(customerId, serviceId);
            if (existed != null)
                return;

            var favorite = new CustomerFavorite
            {
                CustomerId = customerId,
                StoreId = service.StoreId,
                ServiceId = service.Id
            };

            await _favoriteRepository.AddAsync(favorite);
            await _favoriteRepository.SaveChangesAsync();
        }

        public async Task UnfavoriteServiceAsync(int customerId, int serviceId)
        {
            var existed = await _favoriteRepository.GetServiceFavoriteAsync(customerId, serviceId);
            if (existed == null)
                return;

            _favoriteRepository.Remove(existed);
            await _favoriteRepository.SaveChangesAsync();
        }
    }
}