using System;
using System.Collections.Generic;

namespace BeautyBookingSystem.Application.DTOs.StoreStatistics
{
    // DTO cho Biểu đồ doanh thu
    public class RevenueChartItemDto
    {
        public string DateLabel { get; set; } = string.Empty; 
        public decimal TotalRevenue { get; set; }
        public int TotalBookings { get; set; }
    }
}