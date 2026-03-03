using AutoMapper;
using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.DTOs.Store;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
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
            
            var store = await _unitOfWork.StoreRepository
                .GetQueryable()
                .Include(s => s.OperatingHours)
                .FirstOrDefaultAsync(s => s.OwnerId == ownerId);

            if (store == null)
                return "Không tìm thấy cửa hàng.";

            ValidateOperatingHours(request.OperatingHours);

            _mapper.Map(request, store);

            // 3. Xử lý giờ hoạt động 
            store.OperatingHours.Clear();
            foreach (var item in request.OperatingHours)
            {
                store.OperatingHours.Add(new StoreOperatingHour
                {
                    StoreId = store.Id,
                    DayOfWeek = item.DayOfWeek,
                    OpenTime = TimeSpan.Parse(item.OpenTime),
                    CloseTime = TimeSpan.Parse(item.CloseTime)
                });
            }
            _unitOfWork.StoreRepository.Update(store);
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
    }
}