using BeautyBookingSystem.Application.DTOs.Auth;
using BeautyBookingSystem.Application.DTOs.Common;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.IdentityModel.Tokens.Jwt;

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
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier)
             ?? User.FindFirstValue(JwtRegisteredClaimNames.Sub);

            if (string.IsNullOrEmpty(userId))
                return Unauthorized(ApiResponse<bool>.Fail("Token không hợp lệ hoặc không chứa ID."));

            var result = await _authService.ChangePasswordAsync(userId, request);
            return Ok(ApiResponse<bool>.Ok(result, "Đổi mật khẩu thành công!"));
        }

        [HttpPost("logout")]
        [Authorize]
        public async Task<IActionResult> Logout()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier) 
                ?? User.FindFirstValue(JwtRegisteredClaimNames.Sub);

            if (string.IsNullOrEmpty(userId))
                return Unauthorized(ApiResponse<bool>.Fail("Token không hợp lệ!"));

            var result = await _authService.LogoutAsync(userId);
            return Ok(ApiResponse<bool>.Ok(result, "Đăng xuất thành công!"));
        }

        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request)
        {
            var result = await _authService.ForgotPasswordAsync(request);
            return Ok(ApiResponse<bool>.Ok(result, "Mã OTP đã được gửi đến Email của bạn!"));
        }
        [HttpPost("verify-reset-password-otp")]
        public async Task<IActionResult> VerifyResetPasswordOtp([FromBody] VerifyForgotPasswordOtpRequest request)
        {
            var result = await _authService.VerifyForgotPasswordOtpAsync(request);
            return Ok(ApiResponse<bool>.Ok(result, "Xác nhận OTP thành công!"));
        }

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
        {
            var result = await _authService.ResetPasswordAsync(request);
            return Ok(ApiResponse<bool>.Ok(result, "Đặt lại mật khẩu thành công! Bạn có thể đăng nhập bằng mật khẩu mới."));
        }

        [HttpPost("register-partner")]
        public async Task<IActionResult> RegisterPartner([FromBody] RegisterRequest request)
        {
            var result = await _authService.RegisterPartnerAsync(request);
            return Ok(ApiResponse<bool>.Ok(result, "Đăng ký tài khoản Đối tác thành công! Cửa hàng của bạn đang ở trạng thái Chờ phê duyệt. Bạn có thể đăng nhập vào App Đối tác ngay bây giờ."));
        }
        [HttpPost("firebase-login")]
        public async Task<IActionResult> FirebaseLogin([FromBody] FirebaseLoginRequest request)
        {
            var result = await _authService.LoginWithFirebaseAsync(request);
            return Ok(ApiResponse<TokenResponse>.Ok(result, "Đăng nhập thành công!"));
        }
        [HttpPost("verify-phone")]
        [Authorize] 
        public async Task<IActionResult> VerifyPhone([FromBody] VerifyPhoneRequest request)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (string.IsNullOrEmpty(userId))
                return Unauthorized(new { message = "Không xác định được người dùng." });

            var result = await _authService.VerifyPhoneNumberAsync(userId, request.FirebaseIdToken);
            
            return Ok(new { 
                isSuccess = true, 
                message = "Xác thực số điện thoại thành công!" 
            });
        }
    }
}