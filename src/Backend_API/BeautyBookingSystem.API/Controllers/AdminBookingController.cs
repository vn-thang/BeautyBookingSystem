using BeautyBookingSystem.Application.DTOs.AdminBooking;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace BeautyBookingSystem.API.Controllers.Admin
{
    [Route("api/admin/bookings")]
    [ApiController]
    [Authorize(Roles = "Admin")] 
    public class AdminBookingController : ControllerBase
    {
        private readonly IAdminBookingService _adminBookingService;
        public AdminBookingController(IAdminBookingService adminBookingService)
        {
            _adminBookingService = adminBookingService;
        }

        [HttpGet]
        public async Task<IActionResult> GetBookings([FromQuery] AdminBookingFilterRequest request)
        {
            var result = await _adminBookingService.GetBookingsAsync(request);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetBookingDetails(int id)
        {
            var result = await _adminBookingService.GetBookingByIdAsync(id);
            return Ok(result);
        }

        [HttpPut("{id}/cancel")]
        public async Task<IActionResult> CancelBooking(int id, [FromBody] AdminCancelBookingRequest request)
        {
            var result = await _adminBookingService.CancelBookingAsync(id, request);
            return Ok(new { success = result, message = "Đã hủy đơn đặt lịch thành công." });
        }
    }
}