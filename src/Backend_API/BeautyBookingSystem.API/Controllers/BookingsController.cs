using BeautyBookingSystem.Application.DTOs.Booking;
using BeautyBookingSystem.Application.DTOs.Staff;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class BookingsController : ControllerBase
{
    private readonly IBookingService _bookingService;

    public BookingsController(IBookingService bookingService)
    {
        _bookingService = bookingService;
    }

    [HttpPost]
    public async Task<IActionResult> CreateBooking(
        CreateBookingRequest request)
    {
        var userId = int.Parse(
            User.FindFirstValue(ClaimTypes.NameIdentifier)!);

        var booking = await _bookingService
            .CreateBookingAsync(userId, request);

        return Ok(booking);
    }
    // GET /api/bookings  -> list of current user's bookings
    [HttpGet]
    public async Task<IActionResult> GetMyBookings()
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var list = await _bookingService.GetBookingsByCustomerAsync(userId);
        return Ok(list);
    }

    // GET /api/bookings/{id}
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetBookingById(int id)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        var booking = await _bookingService.GetBookingByIdAsync(userId, id);
        if (booking == null) return NotFound();
        return Ok(booking);
    }

    // POST /api/bookings/{id}/cancel
    [HttpPost("{id:int}/cancel")]
    public async Task<IActionResult> CancelBooking(int id, [FromBody] CancelBookingRequest req)
    {
        var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        await _bookingService.CancelBookingAsync(userId, id, req?.Reason);
        return Ok(new { message = "Booking cancelled" });
    }

    [HttpPost("available-staff")]
    public async Task<IActionResult> GetAvailableStaff([FromBody] GetAvailableStaffRequest request)
    {
        var result = await _bookingService.GetAvailableStaffAsync(request);

        return Ok(result);
    }
}