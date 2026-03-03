using BeautyBookingSystem.Application.DTOs.StoreDashboard;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IStoreDashboardService
    {
        Task<StoreDashboardDto> GetDashboardDataAsync(DashboardFilterRequest request);
    }
}
