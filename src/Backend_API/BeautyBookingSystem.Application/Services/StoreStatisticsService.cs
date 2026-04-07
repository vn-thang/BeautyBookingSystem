using BeautyBookingSystem.Application.DTOs.StoreStatistics;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Services
{
    public class StoreStatisticsService : IStoreStatisticsService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUserService _currentUserService;

        public StoreStatisticsService(IUnitOfWork unitOfWork, ICurrentUserService currentUserService)
        {
            _unitOfWork = unitOfWork;
            _currentUserService = currentUserService;
        }

        public async Task<List<RevenueChartItemDto>> GetRevenueChartAsync(DateTime? startDate, DateTime? endDate)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();

            var query = _unitOfWork.BookingRepository.GetQueryable()
                .Where(b => b.StoreId == storeId && b.Status == BookingStatus.Completed);

            if (startDate.HasValue) query = query.Where(b => b.CreatedAt >= startDate.Value);
            if (endDate.HasValue) query = query.Where(b => b.CreatedAt <= endDate.Value);
            var rawData = await query
                .GroupBy(b => b.CreatedAt.Date)
                .Select(g => new 
                {
                    Date = g.Key,
                    TotalRevenue = g.Sum(b => b.TotalPrice),
                    TotalBookings = g.Count()
                })
                .ToListAsync(); 

            var chartData = rawData
                .Select(x => new RevenueChartItemDto
                {
                    DateLabel = x.Date.ToString("yyyy-MM-dd"),
                    TotalRevenue = x.TotalRevenue,
                    TotalBookings = x.TotalBookings
                })
                .OrderBy(x => x.DateLabel) 
                .ToList();

            return chartData;
        }

        public async Task<List<TopPerformanceItemDto>> GetTopServicesAsync(DateTime? startDate, DateTime? endDate, int top = 5)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();

            var query = _unitOfWork.BookingDetailRepository.GetQueryable()
                .Where(bd => bd.Booking.StoreId == storeId 
                          && bd.Booking.Status == BookingStatus.Completed 
                          && bd.Status == BookingDetailStatus.Done); 

            if (startDate.HasValue) query = query.Where(bd => bd.CreatedAt >= startDate.Value);
            if (endDate.HasValue) query = query.Where(bd => bd.CreatedAt <= endDate.Value);

            var topServices = await query
                .GroupBy(bd => new { bd.ServiceId, bd.Service.Name })
                .Select(g => new TopPerformanceItemDto
                {
                    Id = g.Key.ServiceId,
                    Name = g.Key.Name,
                    Count = g.Count(), 
                    Revenue = g.Sum(bd => bd.Price) 
                })
                .OrderByDescending(x => x.Revenue) 
                .Take(top)
                .ToListAsync();

            return topServices;
        }

        public async Task<List<TopPerformanceItemDto>> GetTopStaffsAsync(DateTime? startDate, DateTime? endDate, int top = 5)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();

            var query = _unitOfWork.BookingDetailRepository.GetQueryable()
                .Where(bd => bd.Booking.StoreId == storeId 
                          && bd.Booking.Status == BookingStatus.Completed
                          && bd.Status == BookingDetailStatus.Done
                          && bd.StaffId != null); 

            if (startDate.HasValue) query = query.Where(bd => bd.CreatedAt >= startDate.Value);
            if (endDate.HasValue) query = query.Where(bd => bd.CreatedAt <= endDate.Value);

            var topStaffs = await query
                .GroupBy(bd => new { bd.StaffId, bd.Staff!.FullName }) 
                .Select(g => new TopPerformanceItemDto
                {
                    Id = g.Key.StaffId ?? 0, 
                    Name = g.Key.FullName,
                    Count = g.Count(), 
                    Revenue = g.Sum(bd => bd.Price) 
                })
                .OrderByDescending(x => x.Revenue)
                .Take(top)
                .ToListAsync();

            return topStaffs;
        }

        public async Task<ReviewStatisticsDto> GetReviewStatisticsAsync(DateTime? startDate, DateTime? endDate) // ✨ Thêm parameter
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();

            var query = _unitOfWork.ReviewRepository.GetQueryable()
                .Where(r => r.StoreId == storeId && !r.IsHidden); 

            if (startDate.HasValue) 
                query = query.Where(r => r.CreatedAt >= startDate.Value);
            
            if (endDate.HasValue) 
                query = query.Where(r => r.CreatedAt <= endDate.Value);

            int totalReviews = await query.CountAsync();
            if (totalReviews == 0) return new ReviewStatisticsDto(); 

            double average = await query.AverageAsync(r => r.Rating);

            var starCounts = await query
                .GroupBy(r => r.Rating)
                .Select(g => new { Rating = g.Key, Count = g.Count() })
                .ToListAsync();

            return new ReviewStatisticsDto
            {
                TotalReviews = totalReviews,
                AverageRating = Math.Round(average, 1), 
                FiveStarCount = starCounts.FirstOrDefault(x => x.Rating == 5)?.Count ?? 0,
                FourStarCount = starCounts.FirstOrDefault(x => x.Rating == 4)?.Count ?? 0,
                ThreeStarCount = starCounts.FirstOrDefault(x => x.Rating == 3)?.Count ?? 0,
                TwoStarCount = starCounts.FirstOrDefault(x => x.Rating == 2)?.Count ?? 0,
                OneStarCount = starCounts.FirstOrDefault(x => x.Rating == 1)?.Count ?? 0
            };
        }
        public async Task<List<TopPerformanceItemDto>> GetTopCustomersAsync(DateTime? startDate, DateTime? endDate, int top = 5)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();

            var query = _unitOfWork.BookingRepository.GetQueryable()
                .Where(b => b.StoreId == storeId && b.Status == BookingStatus.Completed);

            if (startDate.HasValue) query = query.Where(b => b.CreatedAt >= startDate.Value);
            if (endDate.HasValue) query = query.Where(b => b.CreatedAt <= endDate.Value);

            var topCustomers = await query
                .GroupBy(b => new { b.CustomerId, b.Customer.FullName }) 
                .Select(g => new TopPerformanceItemDto
                {
                    Id = g.Key.CustomerId,
                    Name = g.Key.FullName ?? "Khách hàng", 
                    Count = g.Count(), 
                    Revenue = g.Sum(b => b.TotalPrice) 
                })
                .OrderByDescending(x => x.Revenue) 
                .Take(top)
                .ToListAsync();

            return topCustomers;
        }

        public async Task<List<StoreRevenueExcelDto>> GetRevenueDataForExportAsync(DateTime? startDate, DateTime? endDate)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();

            var query = _unitOfWork.BookingRepository.GetQueryable()
                .Where(b => b.StoreId == storeId && b.Status == BookingStatus.Completed);
            if (startDate.HasValue) query = query.Where(b => b.CreatedAt >= startDate.Value);
            if (endDate.HasValue) query = query.Where(b => b.CreatedAt <= endDate.Value);

            var rawData = await query
                .Select(b => new
                {
                    BookingId = b.Id,
                    AppointmentDate = b.BookingDetails.OrderBy(d => d.Id).Select(d => (DateTime?)d.AppointmentDate).FirstOrDefault(),
                    CustomerName = b.Customer.FullName,
                    CustomerPhone = b.Customer.Phone,
                    ServiceNames = b.BookingDetails.Select(d => d.Service.Name).ToList(),
                    TotalPrice = b.TotalPrice,
                    DiscountAmount = b.DiscountAmount,
                    FinalPrice = b.FinalPrice,
                    SystemFee = b.SystemFee,
                    DepositAmount = b.DepositAmount,
                    LastPaymentMethod = b.Payments.OrderByDescending(p => p.Id).Select(p => (PaymentMethod?)p.PaymentMethod).FirstOrDefault()
                })
                .OrderBy(x => x.BookingId)
                .ToListAsync();
            var excelData = rawData.Select(x => new StoreRevenueExcelDto
            {
                BookingId = x.BookingId,
                AppointmentDate = x.AppointmentDate.HasValue ? x.AppointmentDate.Value.ToString("dd/MM/yyyy") : "N/A",
                CustomerName = string.IsNullOrEmpty(x.CustomerName) ? "Khách vãng lai" : x.CustomerName,
                CustomerPhone = string.IsNullOrEmpty(x.CustomerPhone) ? "N/A" : x.CustomerPhone,
                UsedServices = x.ServiceNames.Any() ? string.Join(", ", x.ServiceNames) : "N/A",
                
                TotalPrice = x.TotalPrice,
                DiscountAmount = x.DiscountAmount,
                FinalPrice = x.FinalPrice,
                SystemFee = x.SystemFee,
                NetIncome = x.FinalPrice - x.SystemFee,
                
                DepositAmount = x.DepositAmount,
                PaymentMethod = x.LastPaymentMethod.HasValue ? x.LastPaymentMethod.ToString() : "N/A",
                BookingStatus = "Hoàn thành"
            }).ToList();

            return excelData;
        }
    }
}