using BeautyBookingSystem.Application.Common;
using BeautyBookingSystem.Application.DTOs.CustomerStore;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Services
{
    public class PublicStoreService : IPublicStoreService
    {
        private readonly IUnitOfWork _unitOfWork;

        public PublicStoreService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<List<StoreListDto>> GetAllStoresAsync()
        {
            var stores = await _unitOfWork.StoreRepository
                .GetQueryable()
                .Where(s => s.ApprovalStatus == ApprovalStatus.Approved)
                .ToListAsync();

            return stores.Select(s => new StoreListDto
            {
                Id = s.Id,
                Name = s.Name,
                Address = s.Address,
                LogoUrl = s.LogoUrl,
                AverageRating = s.AverageRating,
                TotalReviews = s.TotalReviews,
                IsOpen = s.IsOpen
            }).ToList();
        }

        public async Task<PagedResult<StoreCardDto>> GetStoresByCategoryAsync(StoreQueryParams p)
        {
            var query = _unitOfWork.StoreRepository
                .GetQueryable()
                .Where(s =>
                    s.ApprovalStatus == ApprovalStatus.Approved &&
                    s.Services.Any(se =>
                        se.CategoryId == p.CategoryId &&
                        se.IsActive));

            if (!string.IsNullOrWhiteSpace(p.Q))
            {
                var q = p.Q.Trim().ToLower();
                query = query.Where(s =>
                    s.Name.ToLower().Contains(q) ||
                    s.Services.Any(se => se.CategoryId == p.CategoryId && se.IsActive && se.Name.ToLower().Contains(q)));
            }

            var projected = query.Select(s => new StoreCardDto
            {
                Id = s.Id,
                Name = s.Name,
                Address = s.Address,
                CoverImageUrl = s.CoverImageUrl,
                AverageRating = s.AverageRating
            });

            switch (p.Sort)
            {
                case "rating_desc":
                    projected = projected.OrderByDescending(x => x.AverageRating);
                    break;
                default:
                    projected = projected.OrderBy(x => x.Name);
                    break;
            }

            var total = await projected.CountAsync();

            var items = await projected
                .Skip((p.Page - 1) * p.PageSize)
                .Take(p.PageSize)
                .ToListAsync();

            return new PagedResult<StoreCardDto>
            {
                Page = p.Page,
                PageSize = p.PageSize,
                Total = total,
                Items = items
            };
        }

        public async Task<PagedResult<StoreCardDto>> GetStoresByGroupAsync(StoreQueryParams p)
        {
            if (p.GroupId == null)
            {
                return new PagedResult<StoreCardDto>
                {
                    Page = p.Page,
                    PageSize = p.PageSize,
                    Total = 0,
                    Items = new List<StoreCardDto>()
                };
            }

            var groupId = p.GroupId.Value;

            var query = _unitOfWork.StoreRepository
                .GetQueryable()
                .Where(s =>
                    s.ApprovalStatus == ApprovalStatus.Approved &&
                    s.Services.Any(se => se.GroupId == groupId && se.IsActive));

            if (!string.IsNullOrWhiteSpace(p.Q))
            {
                var q = p.Q.Trim().ToLower();
                query = query.Where(s =>
                    s.Name.ToLower().Contains(q) ||
                    s.Services.Any(se => se.GroupId == groupId && se.IsActive && se.Name.ToLower().Contains(q)));
            }

            var projected = query.Select(s => new StoreCardDto
            {
                Id = s.Id,
                Name = s.Name,
                Address = s.Address,
                CoverImageUrl = s.CoverImageUrl,
                AverageRating = s.AverageRating
            });

            switch (p.Sort)
            {
                case "rating_desc":
                    projected = projected.OrderByDescending(x => x.AverageRating);
                    break;
                default:
                    projected = projected.OrderBy(x => x.Name);
                    break;
            }

            var total = await projected.CountAsync();

            var items = await projected
                .Skip((p.Page - 1) * p.PageSize)
                .Take(p.PageSize)
                .ToListAsync();

            return new PagedResult<StoreCardDto>
            {
                Page = p.Page,
                PageSize = p.PageSize,
                Total = total,
                Items = items
            };
        }

        public async Task<StoreDetailDto?> GetStoreByIdAsync(int storeId, int? customerId = null)
        {
            var store = await _unitOfWork.StoreRepository
                .GetQueryable()
                .Include(s => s.Services)
                .Include(s => s.OperatingHours)
                .Include(s => s.Banners)
                .FirstOrDefaultAsync(s => s.Id == storeId);

            if (store == null) return null;

            var isFavorite = false;

            if (customerId.HasValue)
            {
                isFavorite = await _unitOfWork.CustomerFavoriteRepository
                    .IsStoreFavoriteAsync(customerId.Value, store.Id);
            }

            return new StoreDetailDto
            {
                Id = store.Id,
                Name = store.Name,
                Address = store.Address,
                Phone = store.Phone,
                Description = store.Description,
                ZaloPhone = store.ZaloPhone,
                FacebookUrl = store.FacebookUrl,
                LogoUrl = store.LogoUrl,
                CoverImageUrl = store.CoverImageUrl,
                Latitude = store.Latitude,
                Longitude = store.Longitude,
                IsOpen = store.IsOpen,
                AverageRating = store.AverageRating,
                TotalReviews = store.TotalReviews,
                IsFavorite = isFavorite,
                DepositPercent = store.DepositPercent,
                DepositThreshold = store.DepositThreshold,

                Banners = store.Banners
                    .Where(b => b.IsActive)
                    .OrderBy(b => b.SortOrder)
                    .ThenByDescending(b => b.CreatedAt)
                    .Select(b => new StoreBannerDto
                    {
                        Id = b.Id,
                        ImageUrl = b.ImageUrl,
                        Title = b.Title,
                        Description = b.Description,
                        SortOrder = b.SortOrder
                    }).ToList(),

                Services = store.Services
                    .Where(s => s.IsActive)
                    .OrderBy(s => s.SortOrder)
                    .Select(s => new ServiceItemDto
                    {
                        Id = s.Id,
                        Name = s.Name,
                        Price = s.Price,
                        DurationMinutes = s.DurationMinutes
                    }).ToList(),

                OperatingHours = store.OperatingHours
                    .Select(o => new OperatingHourViewDto
                    {
                        DayOfWeek = (int)o.DayOfWeek,
                        OpenTime = o.OpenTime.ToString(@"hh\:mm"),
                        CloseTime = o.CloseTime.ToString(@"hh\:mm")
                    }).ToList()
            };
        }
    }
}