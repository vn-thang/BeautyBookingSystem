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

            //1. Lấy thông tin Header 
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
                DateTime now = DateTime.Now; // Lưu ý: Nếu server chạy theo giờ UTC thì dùng DateTime.UtcNow
                switch (request.TimeFilter.ToLower())
                {
                    case "today": // Hôm nay
                        request.StartDate = now.Date; // Ví dụ: 00:00:00 hôm nay
                        request.EndDate = now.Date.AddDays(1).AddTicks(-1); // 23:59:59 hôm nay
                        break;
                    case "week": // Tuần này (Thứ 2 đến Chủ nhật)
                        int diff = (7 + (now.DayOfWeek - DayOfWeek.Monday)) % 7;
                        request.StartDate = now.Date.AddDays(-1 * diff);
                        request.EndDate = request.StartDate.Value.AddDays(7).AddTicks(-1);
                        break;
                    case "month": // Tháng này
                        request.StartDate = new DateTime(now.Year, now.Month, 1);
                        request.EndDate = request.StartDate.Value.AddMonths(1).AddTicks(-1);
                        break;
                    case "year": // Năm nay
                        request.StartDate = new DateTime(now.Year, 1, 1);
                        request.EndDate = request.StartDate.Value.AddYears(1).AddTicks(-1);
                        break;
                    case "all": // Tất cả
                        request.StartDate = null;
                        request.EndDate = null;
                        break;
                }
            }


            // 2. Tạo Query cơ bản lọc theo Store và Ngày tháng
            var bookingQuery = _unitOfWork.BookingRepository.GetQueryable()
                .Where(b => b.StoreId == storeId);

            if (request.StartDate.HasValue)
                bookingQuery = bookingQuery.Where(b => b.CreatedAt >= request.StartDate.Value);

            if (request.EndDate.HasValue)
                bookingQuery = bookingQuery.Where(b => b.CreatedAt <= request.EndDate.Value);

            // 3. Thống kê chi tiết
            response.Statistics.TotalBookings = await bookingQuery.CountAsync();

            response.Statistics.TotalCustomers = await bookingQuery
                .Select(b => b.CustomerId)
                .Distinct()
                .CountAsync();

            // Chỉ tính doanh thu các đơn đã hoàn thành
            response.Statistics.TotalRevenue = await bookingQuery
                .Where(b => b.Status == BookingStatus.Completed) 
                .SumAsync(b => b.TotalPrice);

            // 4. Thống kê tiền hoa hồng (Tạm thời gán = 0)
            
            response.Commission.TotalCommission = 0;
            response.Commission.AppUsageFee = 0;
            response.Commission.BalanceToPay = 0;

            // 5. Đơn đặt lịch 
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
