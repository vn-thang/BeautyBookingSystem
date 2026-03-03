using BeautyBookingSystem.Application.DTOs.StoreBooking;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class StoreBookingsController : ControllerBase
    {
        private readonly IStoreBookingService _bookingService;

        public StoreBookingsController(IStoreBookingService bookingService)
        {
            _bookingService = bookingService;
        }

        [HttpGet]
        public async Task<IActionResult> GetBookings([FromQuery] string? status = null)
        {
            var result = await _bookingService.GetBookingsAsync(status);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetBookingDetail(int id)
        {
            var result = await _bookingService.GetBookingDetailAsync(id);
            return Ok(result);
        }

        [HttpGet("available-staffs")]
        public async Task<IActionResult> GetAvailableStaffs(
            [FromQuery] DateTime date,
            [FromQuery] TimeSpan startTime,
            [FromQuery] TimeSpan endTime)
        {
            var result = await _bookingService.GetAvailableStaffsAsync(date, startTime, endTime);
            return Ok(result);
        }

        [HttpPut("{id}/assign-staff")]
        public async Task<IActionResult> AssignStaff(int id, [FromBody] AssignStaffRequest request)
        {
            await _bookingService.AssignStaffAndConfirmAsync(id, request);
            return Ok(new { message = "Đã sắp xếp thợ và xác nhận thành công." });
        }

        [HttpPut("{id}/status")]
        public async Task<IActionResult> UpdateStatus(int id, [FromBody] UpdateBookingStatusRequest request)
        {
            await _bookingService.UpdateStatusAsync(id, request);
            return Ok(new { message = "Cập nhật trạng thái thành công." });
        }
    }
}
