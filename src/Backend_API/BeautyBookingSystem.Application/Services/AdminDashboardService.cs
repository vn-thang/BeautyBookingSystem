using BeautyBookingSystem.Application.DTOs.AdminDashboard;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace BeautyBookingSystem.Application.Services
{
    public class AdminDashboardService : IAdminDashboardService
    {
        private readonly IUnitOfWork _unitOfWork;

        public AdminDashboardService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<AdminDashboardDto> GetDashboardStatisticsAsync()
        {
            var result = new AdminDashboardDto();
            var now = DateTime.UtcNow;

            // 1. LẤY 4 CHỈ SỐ TỔNG QUAN 
            result.TotalUsers = await _unitOfWork.UserRepository.GetQueryable().CountAsync();
            result.TotalStores = await _unitOfWork.StoreRepository.GetQueryable().CountAsync();
            result.TotalBookings = await _unitOfWork.BookingRepository.GetQueryable().CountAsync();

            result.TotalRevenue = await _unitOfWork.BookingRepository.GetQueryable()
                .Where(b => b.Status == BookingStatus.Completed) 
                .SumAsync(b => (decimal?)b.TotalPrice) ?? 0;

            // 2. LẤY DATA BIỂU ĐỒ DOANH THU 6 THÁNG GẦN NHẤT
            var sixMonthsAgo = now.AddMonths(-5);
            var chartData = await _unitOfWork.BookingRepository.GetQueryable()
                .Where(b => b.Status == BookingStatus.Completed && b.CreatedAt >= new DateTime(sixMonthsAgo.Year, sixMonthsAgo.Month, 1))
                .GroupBy(b => new { b.CreatedAt.Year, b.CreatedAt.Month })
                .Select(g => new RevenueChartDto
                {
                    Year = g.Key.Year,
                    Month = g.Key.Month,
                    Revenue = g.Sum(b => b.TotalPrice)
                })
                .OrderBy(c => c.Year).ThenBy(c => c.Month)
                .ToListAsync();

            result.RevenueChart = chartData;

            // 3. LẤY TOP 5 CỬA HÀNG ĐẶT LỊCH NHIỀU NHẤT
            var topStores = await _unitOfWork.BookingRepository.GetQueryable()
                .Where(b => b.Status == BookingStatus.Completed)
                .GroupBy(b => new { b.StoreId, b.Store.Name })
                .Select(g => new TopStoreDto
                {
                    StoreId = g.Key.StoreId,
                    StoreName = g.Key.Name,
                    TotalBookings = g.Count(),
                    TotalRevenue = g.Sum(b => b.TotalPrice)
                })
                .OrderByDescending(x => x.TotalBookings) 
                .Take(5)
                .ToListAsync();

            result.TopStores = topStores;

            return result;
        }
    }
}
