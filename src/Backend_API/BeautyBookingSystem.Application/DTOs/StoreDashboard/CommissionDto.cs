using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.StoreDashboard
{
    public class CommissionDto
    {
        public decimal TotalCommission { get; set; }
        public decimal AppUsageFee { get; set; }
        public decimal BalanceToPay { get; set; }
    }
}
