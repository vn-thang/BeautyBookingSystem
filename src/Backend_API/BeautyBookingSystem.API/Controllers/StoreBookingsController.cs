using BeautyBookingSystem.Application.DTOs.StoreBooking;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "StoreOwner")]
    public class StoreBookingsController : ControllerBase
    {
        private readonly IStoreBookingService _storeBookingService;
        private readonly IBookingService _bookingService;


        public StoreBookingsController(IStoreBookingService storeBookingService, IBookingService bookingService)
        {
            _storeBookingService = storeBookingService;
            _bookingService = bookingService;
        }

        [HttpGet]
        public async Task<IActionResult> GetBookings([FromQuery] string? status = null, [FromQuery] int? staffId = null, [FromQuery] DateTime? startDate=null, [FromQuery] DateTime? endDate=null)
        {
            var result = await _storeBookingService.GetBookingsAsync(status, staffId, startDate, endDate);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetBookingDetail(int id)
        {
            var result = await _storeBookingService.GetBookingDetailAsync(id);
            return Ok(result);
        }

        [HttpGet("available-staffs")]
        public async Task<IActionResult> GetAvailableStaffs(
            [FromQuery] DateTime date,
            [FromQuery] TimeSpan startTime,
            [FromQuery] TimeSpan endTime)
        {
            var result = await _storeBookingService.GetAvailableStaffsAsync(date, startTime, endTime);
            return Ok(result);
        }

        [HttpPut("{id}/assign-staff")]
        public async Task<IActionResult> AssignStaff(int id, [FromBody] AssignStaffRequest request)
        {
            await _storeBookingService.AssignStaffAndConfirmAsync(id, request);
            return Ok(new { message = "Đã sắp xếp thợ và xác nhận thành công." });
        }

        [HttpPut("{id}/status")]
        public async Task<IActionResult> UpdateStatus(int id, [FromBody] UpdateBookingStatusRequest request)
        {
            await _storeBookingService.UpdateStatusAsync(id, request);
            return Ok(new { message = "Cập nhật trạng thái thành công." });
        }

        [HttpPut("{id}/no-show")]
    public async Task<IActionResult> MarkNoShow(int id)
    {
        var storeId = int.Parse(User.FindFirst("StoreId")?.Value ?? "0");
        var result = await _bookingService.MarkAsNoShowAsync(storeId, id);
        return Ok(new { success = true, message = "Đã xác nhận khách không đến." });
    }
    [HttpPost("store-booking")]
        public async Task<IActionResult> CreateOfflineBooking([FromBody] CreateStoreBookingRequest request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            var result = await _storeBookingService.CreateStoreBookingAsync(request);
            
            return Ok(new 
            { 
                success = true, 
                message = "Đã tạo lịch hẹn thành công cho khách hàng vãng lai.",
                data = result 
            });
        }
        [HttpGet("available-time-slots")]
        public async Task<IActionResult> GetAvailableTimeSlots([FromQuery] DateTime date, [FromQuery] int totalDurationMinutes)
        {
            var slots = await _storeBookingService.GetAvailableTimeSlotsAsync(date, totalDurationMinutes);
            return Ok(new { success = true, data = slots });
        }
    }
}
