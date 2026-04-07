using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.AdminDashboard
{
    public class AdminDashboardDto
    {
        public int TotalUsers { get; set; }
        public int TotalStores { get; set; }
        public int TotalBookings { get; set; }
        public decimal TotalRevenue { get; set; }
        public decimal TotalCommission { get; set; }

        public List<RevenueChartDto> RevenueChart { get; set; } = new List<RevenueChartDto>();
        public List<TopStoreDto> TopStores { get; set; } = new List<TopStoreDto>();
        public List<BookingStatusStatsDto> BookingStatusStats { get; set; } = new List<BookingStatusStatsDto>();
        public PendingActionsDto PendingActions { get; set; } = new PendingActionsDto();
    }
}
