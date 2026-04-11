using BeautyBookingSystem.Application.DTOs.StoreStatistics;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IStoreStatisticsService
    {
        Task<List<RevenueChartItemDto>> GetRevenueChartAsync(DateTime? startDate, DateTime? endDate);
        Task<List<TopPerformanceItemDto>> GetTopServicesAsync(DateTime? startDate, DateTime? endDate, int top = 5);
        Task<List<TopPerformanceItemDto>> GetTopStaffsAsync(DateTime? startDate, DateTime? endDate, int top = 5);
        Task<ReviewStatisticsDto> GetReviewStatisticsAsync(DateTime? startDate, DateTime? endDate);
        Task<List<TopPerformanceItemDto>> GetTopCustomersAsync(DateTime? startDate, DateTime? endDate, int top = 5);
        Task<List<StoreRevenueExcelDto>> GetRevenueDataForExportAsync(DateTime? startDate, DateTime? endDate);
    }
}