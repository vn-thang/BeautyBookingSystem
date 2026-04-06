using BeautyBookingSystem.Application.DTOs.AdminDashboard;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Enums;
using System;
using System.Linq;
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

      public async Task<AdminDashboardDto> GetDashboardStatisticsAsync(DateTime? fromDate = null, DateTime? toDate = null)
{
    var result = new AdminDashboardDto();
    var now = DateTime.UtcNow;

    DateTime actualFromDate = fromDate ?? new DateTime(now.Year, now.Month, 1);
    DateTime actualToDate = toDate ?? now;

    var userQuery = _unitOfWork.UserRepository.GetQueryable()
        .Where(u => u.CreatedAt >= actualFromDate && u.CreatedAt <= actualToDate);
        
    var storeQuery = _unitOfWork.StoreRepository.GetQueryable()
        .Where(s => s.CreatedAt >= actualFromDate && s.CreatedAt <= actualToDate);
        
    var bookingQuery = _unitOfWork.BookingRepository.GetQueryable()
        .Where(b => b.CreatedAt >= actualFromDate && b.CreatedAt <= actualToDate);

    var commissionQuery = _unitOfWork.WalletTransactionRepository.GetQueryable()
        .Where(t => t.Type == TransactionType.Commission 
                 && t.CreatedAt >= actualFromDate 
                 && t.CreatedAt <= actualToDate);

    result.TotalUsers = await userQuery.CountAsync();
    result.TotalStores = await storeQuery.CountAsync();
    result.TotalBookings = await bookingQuery.CountAsync();

    result.TotalRevenue = await bookingQuery
        .Where(b => b.Status == BookingStatus.Completed) 
        .SumAsync(b => (decimal?)b.TotalPrice) ?? 0;

    result.TotalCommission = await commissionQuery
        .SumAsync(t => (decimal?)t.Amount) ?? 0;

    var timeSpan = actualToDate - actualFromDate;
    bool isGroupByDay = timeSpan.TotalDays <= 31; 

    var baseChartQuery = _unitOfWork.BookingRepository.GetQueryable()
        .Where(b => b.Status == BookingStatus.Completed 
                 && b.CreatedAt >= actualFromDate 
                 && b.CreatedAt <= actualToDate);

    List<RevenueChartDto> gmvData;
    List<RevenueChartDto> commData;

    if (isGroupByDay)
    {
        gmvData = await baseChartQuery
            .GroupBy(b => new { b.CreatedAt.Year, b.CreatedAt.Month, b.CreatedAt.Day })
            .Select(g => new RevenueChartDto { Year = g.Key.Year, Month = g.Key.Month, Day = g.Key.Day, Revenue = g.Sum(b => b.TotalPrice) })
            .ToListAsync();

        commData = await commissionQuery
            .GroupBy(t => new { t.CreatedAt.Year, t.CreatedAt.Month, t.CreatedAt.Day })
            .Select(g => new RevenueChartDto { Year = g.Key.Year, Month = g.Key.Month, Day = g.Key.Day, Commission = g.Sum(t => t.Amount) })
            .ToListAsync();
    }
    else
    {
        gmvData = await baseChartQuery
            .GroupBy(b => new { b.CreatedAt.Year, b.CreatedAt.Month })
            .Select(g => new RevenueChartDto { Year = g.Key.Year, Month = g.Key.Month, Day = null, Revenue = g.Sum(b => b.TotalPrice) })
            .ToListAsync();

        commData = await commissionQuery
            .GroupBy(t => new { t.CreatedAt.Year, t.CreatedAt.Month })
            .Select(g => new RevenueChartDto { Year = g.Key.Year, Month = g.Key.Month, Day = null, Commission = g.Sum(t => t.Amount) })
            .ToListAsync();
    }

    var allDates = gmvData.Select(x => new { x.Year, x.Month, x.Day })
        .Union(commData.Select(x => new { x.Year, x.Month, x.Day }))
        .Distinct();

    allDates = isGroupByDay 
        ? allDates.OrderBy(x => x.Year).ThenBy(x => x.Month).ThenBy(x => x.Day)
        : allDates.OrderBy(x => x.Year).ThenBy(x => x.Month);

    result.RevenueChart = allDates.Select(date => new RevenueChartDto
    {
        Year = date.Year,
        Month = date.Month,
        Day = date.Day,
        Revenue = gmvData.FirstOrDefault(g => g.Year == date.Year && g.Month == date.Month && g.Day == date.Day)?.Revenue ?? 0,
        Commission = commData.FirstOrDefault(c => c.Year == date.Year && c.Month == date.Month && c.Day == date.Day)?.Commission ?? 0
    }).ToList();

    result.TopStores = await bookingQuery
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

    result.BookingStatusStats = await bookingQuery
        .GroupBy(b => b.Status)
        .Select(g => new BookingStatusStatsDto
        {
            Status = g.Key.ToString(),
            Count = g.Count()
        })
        .ToListAsync();

    var pendingActions = new PendingActionsDto();
    
    pendingActions.PendingStores = await _unitOfWork.StoreRepository.GetQueryable()
        .CountAsync(s => s.ApprovalStatus == ApprovalStatus.Pending);
        
    pendingActions.PendingPayouts = 0; // TODO
    pendingActions.ReportedReviews = 0; // TODO

    result.PendingActions = pendingActions;

    return result;
        }
    }
}