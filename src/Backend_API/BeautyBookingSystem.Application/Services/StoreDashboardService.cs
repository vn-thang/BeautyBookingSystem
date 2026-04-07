using BeautyBookingSystem.Application.DTOs.StoreDashboard;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Services
{
    public class StoreDashboardService : IStoreDashboardService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUserService _currentUserService;

        public StoreDashboardService(IUnitOfWork unitOfWork, ICurrentUserService currentUserService)
        {
            _unitOfWork = unitOfWork;
            _currentUserService = currentUserService;
        }

        public async Task<StoreDashboardDto> GetDashboardDataAsync(DashboardFilterRequest request)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();
            var response = new StoreDashboardDto();
            var store = await _unitOfWork.StoreRepository.GetByIdAsync(storeId);
            if (store != null)
            {
                response.Status = store.ApprovalStatus.ToString().ToLower();
                response.Header = new StoreHeaderDto
                {
                    Name = store.Name,
                    Address = store.Address,
                    LogoUrl = store.LogoUrl 
                };
            }


            if (!string.IsNullOrEmpty(request.TimeFilter))
            {
                DateTime now = DateTime.Now; 
                switch (request.TimeFilter.ToLower())
                {
                    case "today": // Hôm nay
                        request.StartDate = now.Date; 
                        request.EndDate = now.Date.AddDays(1).AddTicks(-1); 
                        break;
                    case "week": 
                        int diff = (7 + (now.DayOfWeek - DayOfWeek.Monday)) % 7;
                        request.StartDate = now.Date.AddDays(-1 * diff);
                        request.EndDate = request.StartDate.Value.AddDays(7).AddTicks(-1);
                        break;
                    case "month": 
                        request.StartDate = new DateTime(now.Year, now.Month, 1);
                        request.EndDate = request.StartDate.Value.AddMonths(1).AddTicks(-1);
                        break;
                    case "year": 
                        request.StartDate = new DateTime(now.Year, 1, 1);
                        request.EndDate = request.StartDate.Value.AddYears(1).AddTicks(-1);
                        break;
                    case "all": 
                        request.StartDate = null;
                        request.EndDate = null;
                        break;
                }
            }
            var bookingQuery = _unitOfWork.BookingRepository.GetQueryable()
                .Where(b => b.StoreId == storeId);

            if (request.StartDate.HasValue)
                bookingQuery = bookingQuery.Where(b => b.CreatedAt >= request.StartDate.Value);

            if (request.EndDate.HasValue)
                bookingQuery = bookingQuery.Where(b => b.CreatedAt <= request.EndDate.Value);

            response.Statistics.TotalBookings = await bookingQuery.CountAsync();

            response.Statistics.TotalCustomers = await bookingQuery
                .Select(b => b.CustomerId)
                .Distinct()
                .CountAsync();

            response.Statistics.TotalRevenue = await bookingQuery
                .Where(b => b.Status == BookingStatus.Completed) 
                .SumAsync(b => b.TotalPrice);
            response.Commission.TotalCommission = await bookingQuery
                .Where(b => b.Status == BookingStatus.Completed)
                .SumAsync(b => b.SystemFee); 

            var transactionQuery = _unitOfWork.WalletTransactionRepository.GetQueryable()
                .Where(t => t.StoreId == storeId);

            if (request.StartDate.HasValue)
                transactionQuery = transactionQuery.Where(t => t.CreatedAt >= request.StartDate.Value);
            if (request.EndDate.HasValue)
                transactionQuery = transactionQuery.Where(t => t.CreatedAt <= request.EndDate.Value);

            response.Commission.AppUsageFee = await transactionQuery
                .Where(t => t.Type == TransactionType.MonthlyFee 
                         && t.Status == TransactionStatus.Completed)
                .SumAsync(t => Math.Abs(t.Amount)); 

            response.Commission.TotalWithdrawn = await transactionQuery
                .Where(t => t.Type == TransactionType.Withdrawal 
                         && t.Status == TransactionStatus.Completed)
                .SumAsync(t => Math.Abs(t.Amount));

            var counts = await bookingQuery
                .GroupBy(b => b.Status)
                .Select(g => new { Status = g.Key, Count = g.Count() })
                .ToListAsync();

            response.BookingCounts.Pending = counts.FirstOrDefault(c => c.Status == BookingStatus.Pending)?.Count ?? 0;
            response.BookingCounts.Confirmed = counts.FirstOrDefault(c => c.Status == BookingStatus.Confirmed)?.Count ?? 0;
            response.BookingCounts.Completed = counts.FirstOrDefault(c => c.Status == BookingStatus.Completed)?.Count ?? 0;
            response.BookingCounts.CancelledByCustomer = counts.FirstOrDefault(c => c.Status == BookingStatus.Cancelled)?.Count ?? 0;

            return response;
        }
    }
}
