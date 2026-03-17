using AutoMapper;
using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.DTOs.Store;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Services
{
    public class StoreService : IStoreService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public StoreService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<StoreProfileDto?> GetStoreProfileAsync(int ownerId)
        {
           
            var store = await _unitOfWork.StoreRepository
                .GetQueryable().
                Include(s => s.OperatingHours)
                .FirstOrDefaultAsync(s => s.OwnerId == ownerId);

            if (store == null) return null;

            return _mapper.Map<StoreProfileDto>(store);
        }

        public async Task<string?> UpdateStoreProfileAsync(int ownerId, StoreProfileDto request)
        {
            // 1. Đã lấy sẵn OperatingHours từ DB lên đây rồi
            var store = await _unitOfWork.StoreRepository
                .GetQueryable()
                .Include(s => s.OperatingHours)
                .FirstOrDefaultAsync(s => s.OwnerId == ownerId);

            if (store == null)
                return "Không tìm thấy cửa hàng.";

            ValidateOperatingHours(request.OperatingHours);
            ValidateCoordinates(request.Latitude, request.Longitude);

            // 2. AutoMapper chạy mượt mà (đã tự động Ignore OperatingHours nhờ config của bạn)
            _mapper.Map(request, store);

            // 3. Xử lý giờ hoạt động tối ưu
            if (request.OperatingHours != null)
            {
                // Dùng luôn store.OperatingHours, KHÔNG CẦN gọi FindAsync nữa
                if (store.OperatingHours != null && store.OperatingHours.Any())
                {
                    // Phải dùng .ToList() trước khi lặp để tránh lỗi "Collection was modified" khi xóa
                    foreach (var oldHour in store.OperatingHours.ToList())
                    {
                        _unitOfWork.StoreOperatingHourRepository.Delete(oldHour);
                    }
                }

                // Thêm giờ mới
                foreach (var item in request.OperatingHours)
                {
                    await _unitOfWork.StoreOperatingHourRepository.AddAsync(new StoreOperatingHour
                    {
                        StoreId = store.Id,
                        DayOfWeek = item.DayOfWeek,
                        OpenTime = TimeSpan.Parse(item.OpenTime),
                        CloseTime = TimeSpan.Parse(item.CloseTime)
                    });
                }
            }

            if (store.ApprovalStatus == ApprovalStatus.Incomplete)
            {
                store.ApprovalStatus = ApprovalStatus.Pending;
            }

            _unitOfWork.StoreRepository.Update(store);

            // 4. Lưu tất cả thay đổi (Update thông tin + Delete giờ cũ + Insert giờ mới) trong 1 Transaction duy nhất
            await _unitOfWork.SaveChangesAsync();

            return null;
        }

        private void ValidateOperatingHours(List<OperatingHourDto>? hours)
        {
            if (hours == null || !hours.Any())
                throw new BadRequestException("Cửa hàng phải có ít nhất 1 ngày làm việc.");

            if (hours.GroupBy(x => x.DayOfWeek).Any(g => g.Count() > 1))
                throw new BadRequestException("Danh sách giờ làm việc có ngày bị lặp lại.");

            foreach (var item in hours)
            {
                if (!TimeSpan.TryParse(item.OpenTime, out var open) || !TimeSpan.TryParse(item.CloseTime, out var close))
                    throw new BadRequestException($"Định dạng giờ không hợp lệ tại {item.DayOfWeek}");

                if (open >= close)
                    throw new BadRequestException($"Giờ mở phải nhỏ hơn giờ đóng tại {item.DayOfWeek}");
            }
        }
        private void ValidateCoordinates(double? lat, double? lng)
        {
            if (lat.HasValue && (lat < -90 || lat > 90))
                throw new BadRequestException("Vĩ độ (Latitude) không hợp lệ (phải từ -90 đến 90).");

            if (lng.HasValue && (lng < -180 || lng > 180))
                throw new BadRequestException("Kinh độ (Longitude) không hợp lệ (phải từ -180 đến 180).");
        }
    }
}