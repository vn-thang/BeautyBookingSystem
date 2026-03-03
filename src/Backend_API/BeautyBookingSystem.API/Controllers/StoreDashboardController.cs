using BeautyBookingSystem.Application.DTOs.StoreDashboard;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers
{
    [Authorize(Roles = "StoreOwner")]
    [ApiController]
    [Route("api/store-dashboard")]
    public class StoreDashboardController : ControllerBase
    {
        private readonly IStoreDashboardService _dashboardService;

        public StoreDashboardController(IStoreDashboardService dashboardService)
        {
            _dashboardService = dashboardService;
        }

        [HttpGet]
        public async Task<IActionResult> GetDashboard([FromQuery] DashboardFilterRequest request)
        {
            var data = await _dashboardService.GetDashboardDataAsync(request);
            return Ok(data);
        }
    }
}
