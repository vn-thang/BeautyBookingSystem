using BeautyBookingSystem.Application.DTOs.Store;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace BeautyBookingSystem.Application.Services
{
    public class StoreService : IStoreService
    {
        private readonly IUnitOfWork _unitOfWork;

        public StoreService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<StoreProfileDto?> GetStoreProfileAsync(int ownerId)
        {
           
            var store = await _unitOfWork.StoreRepository
                .GetQueryable().
                Include(s => s.OperatingHours)
                .FirstOrDefaultAsync(s => s.OwnerId == ownerId);

            if (store == null) return null;

            return new StoreProfileDto
            {
                Name = store.Name,
                Address = store.Address,
                Phone = store.Phone,
                Description = store.Description,
                LogoUrl = store.LogoUrl,
                CoverImageUrl = store.CoverImageUrl,
                Latitude = store.Latitude,
                Longitude = store.Longitude,
                IsOpen = store.IsOpen,
                AverageRating = store.AverageRating, 
                TotalReviews = store.TotalReviews,
                OperatingHours = store.OperatingHours.Select(oh => new OperatingHourDto
                {
                    DayOfWeek = oh.DayOfWeek,
                    OpenTime = oh.OpenTime.ToString(@"hh\:mm"),
                    CloseTime = oh.CloseTime.ToString(@"hh\:mm")
                }).ToList()
            };
        }

        public async Task<string?> UpdateStoreProfileAsync(int ownerId, StoreProfileDto request)
        {
            
            var store = await _unitOfWork.StoreRepository
                .GetQueryable()
                .Include(s => s.OperatingHours)
                .FirstOrDefaultAsync(s => s.OwnerId == ownerId);

            if (store == null)
                return "Không tìm thấy cửa hàng.";

            if (request.OperatingHours == null || !request.OperatingHours.Any())
                return "Cửa hàng phải có ít nhất 1 ngày làm việc.";
            var duplicateDays = request.OperatingHours.GroupBy(x => x.DayOfWeek).Any(g => g.Count() > 1);
            if (duplicateDays) return "Danh sách giờ làm việc có ngày bị lặp lại.";

            store.Name = request.Name;
            store.Address = request.Address;
            store.Phone = request.Phone;
            store.Description = request.Description;
            store.LogoUrl = request.LogoUrl;
            store.CoverImageUrl = request.CoverImageUrl;
            store.Latitude = request.Latitude;
            store.Longitude = request.Longitude;
            store.IsOpen = request.IsOpen;

            store.OperatingHours.Clear();

            foreach (var item in request.OperatingHours)
            {
                if (!TimeSpan.TryParse(item.OpenTime, out var openTime))
                    return $"Giờ mở không hợp lệ ({item.DayOfWeek})";

                if (!TimeSpan.TryParse(item.CloseTime, out var closeTime))
                    return $"Giờ đóng không hợp lệ ({item.DayOfWeek})";

                if (openTime >= closeTime)
                    return $"Giờ mở phải nhỏ hơn giờ đóng ({item.DayOfWeek})";

                store.OperatingHours.Add(new StoreOperatingHour
                {
                    StoreId = store.Id,
                    DayOfWeek = item.DayOfWeek,
                    OpenTime = openTime,
                    CloseTime = closeTime
                });
                
            }
            _unitOfWork.StoreRepository.Update(store);
            await _unitOfWork.SaveChangesAsync();

            return null; 
        }
    }
}