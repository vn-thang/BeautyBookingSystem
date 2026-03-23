using BeautyBookingSystem.Application.Common.Helpers;
using BeautyBookingSystem.Application.DTOs.Search;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace BeautyBookingSystem.Application.Services
{
    public class SearchService : ISearchService
    {
        private readonly IUnitOfWork _unitOfWork;

        public SearchService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<List<SearchStoreResponse>> SearchAsync(SearchRequest request)
        {
            var query = _unitOfWork.StoreRepository
                .GetQueryable()
                .AsNoTracking()
                .Where(s => s.IsOpen);

            if (!string.IsNullOrWhiteSpace(request.Keyword))
            {
                var keyword = request.Keyword.Trim();

                query = query.Where(s =>
                    EF.Functions.Like(s.Name, $"%{keyword}%") ||
                    EF.Functions.Like(s.Address, $"%{keyword}%") ||
                    s.Services.Any(sv =>
                        sv.IsActive &&
                        EF.Functions.Like(sv.Name, $"%{keyword}%")));
            }

            if (!string.IsNullOrWhiteSpace(request.Location))
            {
                var location = request.Location.Trim();

                query = query.Where(s =>
                    EF.Functions.Like(s.Address, $"%{location}%"));
            }

            if (request.MinRating.HasValue)
            {
                query = query.Where(s => s.AverageRating >= request.MinRating.Value);
            }

            if (request.MinPrice.HasValue || request.MaxPrice.HasValue)
            {
                query = query.Where(s =>
                    s.Services.Any(sv =>
                        sv.IsActive &&
                        (!request.MinPrice.HasValue || sv.Price >= request.MinPrice.Value) &&
                        (!request.MaxPrice.HasValue || sv.Price <= request.MaxPrice.Value)));
            }

            var stores = await query
                .Include(s => s.Services)
                .ToListAsync();

            var result = stores.Select(s =>
            {
                double distance = double.MaxValue;

                if (request.UserLat.HasValue &&
                    request.UserLng.HasValue &&
                    s.Latitude.HasValue &&
                    s.Longitude.HasValue)
                {
                    distance = GeoHelper.CalculateDistanceKm(
                        request.UserLat.Value,
                        request.UserLng.Value,
                        s.Latitude.Value,
                        s.Longitude.Value);
                }

                var services = s.Services
                    .Where(sv => sv.IsActive)
                    .Where(sv =>
                        (!request.MinPrice.HasValue || sv.Price >= request.MinPrice.Value) &&
                        (!request.MaxPrice.HasValue || sv.Price <= request.MaxPrice.Value))
                    .OrderBy(sv => sv.Price)
                    .Take(3)
                    .Select(sv => new SearchServiceResponse
                    {
                        Id = sv.Id,
                        Name = sv.Name,
                        Price = sv.Price
                    })
                    .ToList();

                return new SearchStoreResponse
                {
                    Id = s.Id,
                    Name = s.Name,
                    Address = s.Address,
                    ImageUrl = s.LogoUrl,
                    Rating = s.AverageRating,
                    DistanceKm = distance,
                    Lat = s.Latitude,
                    Lng = s.Longitude,
                    MinServicePrice = services.Count > 0 ? services.Min(x => x.Price) : 0m,
                    Services = services
                };
            }).ToList();

            result = request.SortBy switch
            {
                "topRated" => result
                    .OrderByDescending(x => x.Rating)
                    .ThenBy(x => x.DistanceKm)
                    .ToList(),

                "location" => result
                    .OrderBy(x => x.Address)
                    .ToList(),

                _ => result
                    .OrderBy(x => x.DistanceKm)
                    .ToList(),
            };

            return result;
        }
    }
}