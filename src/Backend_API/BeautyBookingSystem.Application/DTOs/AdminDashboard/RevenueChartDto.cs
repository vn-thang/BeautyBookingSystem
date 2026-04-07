using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.AdminDashboard
{
    public class RevenueChartDto
    {
        public int Month { get; set; }
        public int Year { get; set; }
        public int? Day { get; set; }
        public decimal Revenue { get; set; }
        public decimal Commission { get; set; }
    }
}
