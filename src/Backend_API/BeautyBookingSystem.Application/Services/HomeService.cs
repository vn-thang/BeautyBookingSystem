using BeautyBookingSystem.Application.Common.Helpers;
using BeautyBookingSystem.Application.DTOs.GlobalCategory;
using BeautyBookingSystem.Application.DTOs.Home;
using BeautyBookingSystem.Application.DTOs.ServiceGroup;
using BeautyBookingSystem.Application.DTOs.Store;
using BeautyBookingSystem.Application.DTOs.SystemContent;
using BeautyBookingSystem.Application.DTOs.Voucher;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace BeautyBookingSystem.Application.Services
{
    public class HomeService : IHomeService
    {
        private readonly IUnitOfWork _unitOfWork;

        public HomeService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<HomeResponseDto> GetHomeDataAsync(
            Guid? userId,
            double? lat,
            double? lon)
        {
            /// ===== CATEGORIES =====
            var categories = await _unitOfWork
                .GlobalCategoryRepository
                .GetQueryable()
                .Take(10)
                .Select(x => new GlobalCategoryDto
                {
                    Id = x.Id,
                    Name = x.Name,
                    IconUrl = x.IconUrl
                })
                .ToListAsync();

            /// ===== SERVICE GROUPS =====
            var groups = await _unitOfWork
                .ServiceGroupRepository
                .GetQueryable()
                .Select(x => new ServiceGroupDto
                {
                    Id = x.Id,
                    Name = x.Name
                })
                .ToListAsync();

            /// ===== STORES BASE =====
            var storeQuery = _unitOfWork
                .StoreRepository
                .GetQueryable()
                .Where(s =>
                    s.ApprovalStatus == ApprovalStatus.Approved &&
                    s.Latitude != null &&
                    s.Longitude != null);

            var stores = await storeQuery.ToListAsync();

            bool hasValidLocation =
                lat.HasValue && lon.HasValue &&
                lat.Value != 0 && lon.Value != 0;

            /// ===== NEARBY STORES =====
            var nearbyStores = stores
                .Select(s =>
                {
                    double distance = 0;

                    if (hasValidLocation)
                    {
                        distance = GeoHelper.CalculateDistanceKm(
                            lat!.Value,
                            lon!.Value,
                            s.Latitude!.Value,
                            s.Longitude!.Value);
                    }

                    return new StoreNearbyDto
                    {
                        Id = s.Id,
                        Name = s.Name,
                        Address = s.Address,
                        LogoUrl = s.LogoUrl,
                        CoverImageUrl = s.CoverImageUrl,
                        Latitude = s.Latitude,
                        Longitude = s.Longitude,
                        DistanceKm = distance,
                        AverageRating = (double)s.AverageRating,
                        TotalReviews = s.TotalReviews
                    };
                })
                .OrderBy(x => hasValidLocation ? x.DistanceKm : 0)
                .Take(10)
                .ToList();

            /// ===== TOP RATED STORES =====
            var topRatedStores = stores
                .Select(s =>
                {
                    double distance = 0;

                    if (hasValidLocation)
                    {
                        distance = GeoHelper.CalculateDistanceKm(
                            lat!.Value,
                            lon!.Value,
                            s.Latitude!.Value,
                            s.Longitude!.Value);
                    }

                    return new StoreNearbyDto
                    {
                        Id = s.Id,
                        Name = s.Name,
                        Address = s.Address,
                        LogoUrl = s.LogoUrl,
                        CoverImageUrl = s.CoverImageUrl,
                        Latitude = s.Latitude,
                        Longitude = s.Longitude,
                        DistanceKm = distance,
                        AverageRating = (double)s.AverageRating,
                        TotalReviews = s.TotalReviews
                    };
                })
                .OrderByDescending(x => x.AverageRating)
                .ThenByDescending(x => x.TotalReviews)
                .Take(10)
                .ToList();

            /// ===== VOUCHERS (FIXED) =====
            var vouchers = await _unitOfWork
                .VoucherRepository
                .GetQueryable()
                .Where(v => v.Service != null) 
                .OrderByDescending(v => v.StartDate)
                .Take(8)
                .Select(v => new ServiceVoucherHomeDto
                {
                    Id = v.Id,
                    StoreId = v.StoreId,
                    ServiceId = v.ServiceId,

                    Code = v.Code,
                    ImageUrl = v.ImageUrl,

                    ServiceName = v.Service!.Name,

                    OriginalPrice = v.Service.Price,

                    DiscountType = v.DiscountType,
                    DiscountValue = v.DiscountValue,
                    MinOrderValue = v.MinOrderValue,
                    MaxDiscount = v.MaxDiscount,

                    DiscountAmount = v.DiscountType == DiscountType.Percentage
                        ? (v.Service.Price * v.DiscountValue / 100)
                        : v.DiscountValue,

                    DiscountedPrice = v.DiscountType == DiscountType.Percentage
                        ? v.Service.Price - (v.Service.Price * v.DiscountValue / 100)
                        : v.Service.Price - v.DiscountValue,

                    StartDate = v.StartDate,
                    EndDate = v.EndDate
                })
                .ToListAsync();

            /// ===== BANNERS =====
            var banners = await _unitOfWork
                .SystemContentRepository
                .GetQueryable()
                .Where(x => x.Type == SystemContentType.Banner && x.IsActive)
                .Select(x => new SystemContentDto
                {
                    Id = x.Id,
                    Type = (int)x.Type,
                    Title = x.Title,
                    Content = x.Content,
                    IsActive = x.IsActive
                })
                .ToListAsync();

            /// ===== RESPONSE =====
            return new HomeResponseDto
            {
                UserName = "User",
                Categories = categories,
                ServiceGroups = groups,
                NearbyStores = nearbyStores,
                TopRatedStores = topRatedStores,
                Vouchers = vouchers,
                SystemContents = banners
            };
        }
    }
}