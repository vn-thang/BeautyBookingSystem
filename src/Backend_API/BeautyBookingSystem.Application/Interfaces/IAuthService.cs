using BeautyBookingSystem.Application.DTOs.Auth;
using BeautyBookingSystem.Application.DTOs.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IAuthService
    {
        Task<ApiResponse<TokenResponse>> RegisterAsync(RegisterRequest request);
        Task<ApiResponse<TokenResponse>> LoginAsync(LoginRequest request);
        Task<ApiResponse<TokenResponse>> RefreshTokenAsync(RefreshTokenRequest request);
        Task<ApiResponse<bool>> ChangePasswordAsync(string userId, ChangePasswordRequest request);
        Task<ApiResponse<bool>> LogoutAsync(string userId);
        Task<ApiResponse<bool>> ForgotPasswordAsync(ForgotPasswordRequest request);
        Task<ApiResponse<bool>> ResetPasswordAsync(ResetPasswordRequest request);
        Task<ApiResponse<bool>> RegisterPartnerAsync(RegisterPartnerRequest request);
    }
}
