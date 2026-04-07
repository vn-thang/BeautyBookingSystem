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

    private int GetUserId()
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (string.IsNullOrEmpty(userIdStr))
            throw new UnauthorizedAccessException("User not authenticated");

        return int.Parse(userIdStr);
    }

    [HttpPost]
    public async Task<IActionResult> CreateBooking(CreateBookingRequest request)
    {
        try
        {
            var userId = GetUserId();

            var booking = await _bookingService.CreateBookingAsync(userId, request);

            return Ok(booking);
        }
        catch (Exception ex)
        {
            return BadRequest(new
            {
                success = false,
                message = ex.Message
            });
        }
    }


    [HttpGet]
    public async Task<IActionResult> GetMyBookings()
    {
        try
        {
            var userId = GetUserId();
            var list = await _bookingService.GetBookingsByCustomerAsync(userId);

            return Ok(list);
        }
        catch (Exception ex)
        {
            return BadRequest(new
            {
                success = false,
                message = ex.Message
            });
        }
    }


    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetBookingById(int id)
    {
        try
        {
            var userId = GetUserId();
            var booking = await _bookingService.GetBookingByIdAsync(userId, id);

            if (booking == null)
                return NotFound(new
                {
                    success = false,
                    message = "Booking not found"
                });

            return Ok(booking);
        }
        catch (Exception ex)
        {
            return BadRequest(new
            {
                success = false,
                message = ex.Message
            });
        }
    }

    [HttpPost("{id:int}/cancel")]
    public async Task<IActionResult> CancelBooking(
        int id,
        [FromBody] CancelBookingRequest req)
    {
        try
        {
            var userId = GetUserId();

            var result = await _bookingService.CancelBookingAsync(
                userId,
                id,
                req?.Reason
            );

            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            // business rule error (VD: quá 24h)
            return BadRequest(new
            {
                success = false,
                message = ex.Message
            });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new
            {
                success = false,
                message = "Booking not found"
            });
        }
        catch (UnauthorizedAccessException)
        {
            return StatusCode(403, new
            {
                success = false,
                message = "You are not allowed to cancel this booking"
            });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new
            {
                success = false,
                message = "Internal server error",
                detail = ex.Message
            });
        }
    }


    [HttpPost("available-staff")]
    public async Task<IActionResult> GetAvailableStaff(GetAvailableStaffRequest request)
    {
        try
        {
            var result = await _bookingService.GetAvailableStaffAsync(request);

            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new
            {
                success = false,
                message = ex.Message
            });
        }
    }
}

public class CancelBookingRequest
{
    public string? Reason { get; set; }
}