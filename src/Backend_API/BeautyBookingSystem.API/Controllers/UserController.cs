using BeautyBookingSystem.Application.DTOs.User;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BeautyBookingSystem.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class UserController : ControllerBase
    {
        private readonly IUserService _userService;

        public UserController(IUserService userService)
        {
            _userService = userService;
        }

        // 1. API GET: api/user/me (Xem hồ sơ)
        [HttpGet("me")]
        public async Task<IActionResult> GetProfile()
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId)) return Unauthorized();

                var profile = await _userService.GetProfileAsync(userId);
                return Ok(profile);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        // 2. API PUT: api/user/profile (Cập nhật hồ sơ)
        [HttpPut("profile")]
        public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileRequest request)
        {
            try
            {
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
                if (string.IsNullOrEmpty(userId)) return Unauthorized();

                await _userService.UpdateProfileAsync(userId, request);
                return Ok(new { message = "Cập nhật thông tin thành công!" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }
    }
}
