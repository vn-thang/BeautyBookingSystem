using BeautyBookingSystem.Application.Common.Helpers;
using BeautyBookingSystem.Application.DTOs;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace BeautyBookingSystem.Infrastructure.Repositories
{
    public class CustomerFavoriteRepository : ICustomerFavoriteRepository
    {
        private readonly AppDbContext _context;

        public CustomerFavoriteRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<CustomerFavorite?> GetStoreFavoriteAsync(int customerId, int storeId)
        {
            return await _context.CustomerFavorites
                .FirstOrDefaultAsync(x =>
                    x.CustomerId == customerId &&
                    x.StoreId == storeId &&
                    x.ServiceId == null);
        }

        public async Task<CustomerFavorite?> GetServiceFavoriteAsync(int customerId, int serviceId)
        {
            return await _context.CustomerFavorites
                .FirstOrDefaultAsync(x =>
                    x.CustomerId == customerId &&
                    x.ServiceId == serviceId);
        }

        public async Task AddAsync(CustomerFavorite favorite)
        {
            await _context.CustomerFavorites.AddAsync(favorite);
        }

        public void Remove(CustomerFavorite favorite)
        {
            _context.CustomerFavorites.Remove(favorite);
        }

        public async Task<int> SaveChangesAsync()
        {
            return await _context.SaveChangesAsync();
        }

        public async Task<bool> IsStoreFavoriteAsync(int customerId, int storeId)
        {
            return await _context.CustomerFavorites
                .AnyAsync(x =>
                    x.CustomerId == customerId &&
                    x.StoreId == storeId &&
                    x.ServiceId == null);
        }

        public async Task<bool> IsServiceFavoriteAsync(int customerId, int serviceId)
        {
            return await _context.CustomerFavorites
                .AnyAsync(x =>
                    x.CustomerId == customerId &&
                    x.ServiceId == serviceId);
        }

        public async Task<List<FavoriteStoreDto>> GetFavoriteStoresAsync(
            int customerId,
            double? latitude,
            double? longitude)
        {
            var stores = await (
                from f in _context.CustomerFavorites.AsNoTracking()
                join s in _context.Stores.AsNoTracking() on f.StoreId equals s.Id
                where f.CustomerId == customerId
                      && f.StoreId != null
                      && f.ServiceId == null
                select new
                {
                    s.Id,
                    s.Name,
                    s.Address,
                    s.LogoUrl,
                    s.CoverImageUrl,
                    AverageRating = (double?)s.AverageRating,
                    s.TotalReviews,
                    s.Latitude,
                    s.Longitude
                }
            ).ToListAsync();

            return stores
                .Select(x => new FavoriteStoreDto
                {
                    Id = x.Id,
                    Name = x.Name,
                    Address = x.Address,
                    LogoUrl = x.LogoUrl,
                    CoverImageUrl = x.CoverImageUrl,
                    AverageRating = x.AverageRating,
                    TotalReviews = x.TotalReviews,
                    DistanceKm = latitude.HasValue
                                  && longitude.HasValue
                                  && x.Latitude.HasValue
                                  && x.Longitude.HasValue
                        ? GeoHelper.CalculateDistanceKm(
                            latitude.Value,
                            longitude.Value,
                            x.Latitude.Value,
                            x.Longitude.Value)
                        : null
                })
                .OrderBy(x => x.DistanceKm ?? double.MaxValue)
                .ToList();
        }

        public async Task<List<FavoriteServiceDto>> GetFavoriteServicesAsync(int customerId)
        {
            var serviceIds = await _context.CustomerFavorites
                .AsNoTracking()
                .Where(x => x.CustomerId == customerId && x.ServiceId != null)
                .Select(x => x.ServiceId!.Value)
                .Distinct()
                .ToListAsync();

            if (serviceIds.Count == 0)
                return new List<FavoriteServiceDto>();

            return await _context.Services
                .AsNoTracking()
                .Where(x => serviceIds.Contains(x.Id))
                .Select(x => new FavoriteServiceDto
                {
                    Id = x.Id,
                    StoreId = x.StoreId,
                    StoreName = x.Store != null ? x.Store.Name : null,
                    Name = x.Name,
                    ImageUrl = x.ImageUrl,
                    Price = x.Price,
                    DurationMinutes = x.DurationMinutes
                })
                .ToListAsync();
        }
    }
}