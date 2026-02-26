using BeautyBookingSystem.Application.DTOs.Auth;
using BeautyBookingSystem.Application.DTOs.Common;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BeautyBookingSystem.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterRequest request)
        {
            var result = await _authService.RegisterAsync(request);
            return Ok(ApiResponse<TokenResponse>.Ok(result, "Đăng ký thành công!"));
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            var result = await _authService.LoginAsync(request);
            return Ok(ApiResponse<TokenResponse>.Ok(result, "Đăng nhập thành công!"));
        }

        [HttpPost("refresh-token")]
        public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenRequest request)
        {
            var result = await _authService.RefreshTokenAsync(request);
            return Ok(ApiResponse<TokenResponse>.Ok(result, "Làm mới token thành công!"));
        }

        [HttpPut("change-password")]
        [Authorize] 
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
        {
            try
            {
               
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized("Token không hợp lệ hoặc không chứa ID.");
                }

                // Gọi tới hàm xử lý logic ở Bước 2
                var result = await _authService.ChangePasswordAsync(userId, request);

                return Ok(new { message = "Đổi mật khẩu thành công!" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }
        [HttpPost("logout")]
        [Authorize] 
        public async Task<IActionResult> Logout()
        {
            try
            {
                // Tự động bóc ID từ trong Token gửi lên
                var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

                if (string.IsNullOrEmpty(userId))
                {
                    return Unauthorized(new { message = "Token không hợp lệ!" });
                }

                // Gọi hàm xóa RefreshToken
                await _authService.LogoutAsync(userId);

                return Ok(new { message = "Đăng xuất thành công!" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request)
        {
            try
            {
                await _authService.ForgotPasswordAsync(request);
                return Ok(new { message = "Mã OTP đã được gửi đến Email của bạn!" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
        {
            try
            {
                await _authService.ResetPasswordAsync(request);
                return Ok(new { message = "Đặt lại mật khẩu thành công! Bạn có thể đăng nhập bằng mật khẩu mới." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }
    }
}
