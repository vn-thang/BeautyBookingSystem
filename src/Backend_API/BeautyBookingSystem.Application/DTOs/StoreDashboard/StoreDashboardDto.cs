using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.StoreDashboard
{
    public class StoreDashboardDto
    {
        public string Status { get; set; } = "Pending";
        public StoreHeaderDto Header { get; set; } = new();
        public StatisticsDto Statistics { get; set; } = new();
        public CommissionDto Commission { get; set; } = new();
        public BookingCountsDto BookingCounts { get; set; } = new();
    }
}
