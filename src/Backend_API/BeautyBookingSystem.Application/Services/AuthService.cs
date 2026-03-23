using BeautyBookingSystem.Application.Common.Exceptions; 
using BeautyBookingSystem.Application.DTOs.Auth;
using BeautyBookingSystem.Application.DTOs.Common;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Domain.Enums;

using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

namespace BeautyBookingSystem.Application.Services
{
    public class AuthService : IAuthService
    {
        private readonly IEmailService _emailService;
        private readonly IConfiguration _config;
        private readonly IUnitOfWork _unitOfWork;

        public AuthService(IConfiguration config, IUnitOfWork unitOfWork, IEmailService emailService)
        {
            _config = config;
            _unitOfWork = unitOfWork;
            _emailService = emailService;
        }
        public async Task<ApiResponse<TokenResponse>> RegisterAsync(RegisterRequest request)
        {
            var existingUser = await _unitOfWork.UserRepository.FirstOrDefaultAsync(u => u.Phone == request.Phone);
            if (existingUser != null)
                return ApiResponse<TokenResponse>.Fail("Số điện thoại đã được đăng ký");

            var existingEmail = await _unitOfWork.UserRepository.FirstOrDefaultAsync(u => u.Email == request.Email);
            if (existingEmail != null)
                return ApiResponse<TokenResponse>.Fail("Email đã được sử dụng");

            string hashedPassword = BCrypt.Net.BCrypt.HashPassword(request.Password);

            var newUser = new User
            {
                FullName = request.FullName,
                Phone = request.Phone,
                Email = request.Email,
                PasswordHash = hashedPassword,
                Role = Role.Customer,
                Status = UserStatus.Active
            };

            await _unitOfWork.UserRepository.AddAsync(newUser);
            await _unitOfWork.SaveChangesAsync();

            var token = await GenerateTokensAndUpdateUserAsync(newUser);

            return ApiResponse<TokenResponse>.Ok(token, "Đăng ký thành công");
        }

        public async Task<ApiResponse<TokenResponse>> LoginAsync(LoginRequest request)
        {
            var user = await _unitOfWork.UserRepository.FirstOrDefaultAsync(
                u => u.Phone == request.EmailOrPhone || u.Email == request.EmailOrPhone);

            if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            {
                return new ApiResponse<TokenResponse>
                {
                    Success = false,
                    Message = "Số điện thoại/Email hoặc mật khẩu không đúng."
                };
            }

            if (user.Status != UserStatus.Active)
            {
                return new ApiResponse<TokenResponse>
                {
                    Success = false,
                    Message = "Tài khoản của bạn đã bị khóa."
                };
            }

            if (!string.IsNullOrEmpty(request.FcmToken))
            {
                user.FcmToken = request.FcmToken;
            }

            var token = await GenerateTokensAndUpdateUserAsync(user);

            return new ApiResponse<TokenResponse>
            {
                Success = true,
                Data = token
            };
        }

        public async Task<ApiResponse<TokenResponse>> RefreshTokenAsync(RefreshTokenRequest request)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(request.AccessToken) || string.IsNullOrWhiteSpace(request.RefreshToken))
                    return ApiResponse<TokenResponse>.Fail("Token không hợp lệ");

                var principal = GetPrincipalFromExpiredToken(request.AccessToken);
                if (principal == null)
                    return ApiResponse<TokenResponse>.Fail("Token không hợp lệ");

                var userId = principal.Claims
                    .FirstOrDefault(x => x.Type == ClaimTypes.NameIdentifier)?.Value
                    ?? principal.Claims
                    .FirstOrDefault(x => x.Type == JwtRegisteredClaimNames.Sub)?.Value;

                if (string.IsNullOrWhiteSpace(userId))
                    return ApiResponse<TokenResponse>.Fail("Không lấy được userId từ token");

                if (!int.TryParse(userId, out var parsedUserId))
                    return ApiResponse<TokenResponse>.Fail("userId không hợp lệ");

                var user = await _unitOfWork.UserRepository.GetByIdAsync(parsedUserId);

                if (user == null)
                    return ApiResponse<TokenResponse>.Fail("Không tìm thấy user");

                if (string.IsNullOrEmpty(user.RefreshToken) || user.RefreshToken != request.RefreshToken)
                    return ApiResponse<TokenResponse>.Fail("Refresh token không hợp lệ");

                if (user.RefreshTokenExpiryTime == null || user.RefreshTokenExpiryTime < DateTime.UtcNow)
                    return ApiResponse<TokenResponse>.Fail("Refresh token đã hết hạn");

                var token = await GenerateTokensAndUpdateUserAsync(user);

                return ApiResponse<TokenResponse>.Ok(token, "Refresh thành công");
            }
            catch (Exception ex)
            {
                return ApiResponse<TokenResponse>.Fail(ex.Message);
            }
        }

        private async Task<TokenResponse> GenerateTokensAndUpdateUserAsync(User user)
        {
            var accessToken = CreateAccessToken(user);
            var refreshToken = CreateRefreshToken();

            user.RefreshToken = refreshToken;
            user.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(7);

            _unitOfWork.UserRepository.Update(user);
            await _unitOfWork.SaveChangesAsync();

            return new TokenResponse { AccessToken = accessToken, RefreshToken = refreshToken };
        }

        private string CreateAccessToken(User user)
        {

            var claims = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new Claim(ClaimTypes.Name, user.FullName),
                new Claim(ClaimTypes.MobilePhone, user.Phone),
                new Claim(ClaimTypes.Role, user.Role.ToString())
            };


            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]!));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _config["Jwt:Issuer"],    
                audience: _config["Jwt:Audience"],
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(15),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        private string CreateRefreshToken()
        {
            var randomNumber = new byte[32];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomNumber); //Fill dữ liệu ngẫu nhiên vào mảng byte.
            return Convert.ToBase64String(randomNumber);
        }

        private ClaimsPrincipal? GetPrincipalFromExpiredToken(string token)
        {
            var tokenValidationParameters = new TokenValidationParameters
            {
                ValidateAudience = false,
                ValidateIssuer = false,
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]!)),
                ValidateLifetime = false
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var principal = tokenHandler.ValidateToken(token, tokenValidationParameters, out SecurityToken securityToken);

            if (securityToken is not JwtSecurityToken jwtSecurityToken ||
                !jwtSecurityToken.Header.Alg.Equals(SecurityAlgorithms.HmacSha256, StringComparison.InvariantCultureIgnoreCase))
            {
                throw new SecurityTokenException("Token không đúng định dạng chữ ký");
            }

            return principal;
        }

        public async Task<ApiResponse<bool>> ChangePasswordAsync(string userId, ChangePasswordRequest request)
        {
            var user = await _unitOfWork.UserRepository.GetByIdAsync(int.Parse(userId));

            if (!BCrypt.Net.BCrypt.Verify(request.OldPassword, user.PasswordHash))
                return ApiResponse<bool>.Fail("Mật khẩu cũ không đúng");

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);

            _unitOfWork.UserRepository.Update(user);
            await _unitOfWork.SaveChangesAsync();

            return ApiResponse<bool>.Ok(true, "Đổi mật khẩu thành công");
        }

        public async Task<ApiResponse<bool>> LogoutAsync(string userId)
        {
            var user = await _unitOfWork.UserRepository.GetByIdAsync(int.Parse(userId));

            if (user == null)
                return ApiResponse<bool>.Fail("Không tìm thấy user");

            user.RefreshToken = null;
            user.RefreshTokenExpiryTime = null;

            _unitOfWork.UserRepository.Update(user);
            await _unitOfWork.SaveChangesAsync();

            return ApiResponse<bool>.Ok(true, "Đăng xuất thành công");
        }

        public async Task<ApiResponse<bool>> ForgotPasswordAsync(ForgotPasswordRequest request)
        {
            var user = await _unitOfWork.UserRepository.FirstOrDefaultAsync(u => u.Email == request.Email);
            if (user == null)
                return ApiResponse<bool>.Fail("Email chưa được đăng ký");

            string otp = new Random().Next(100000, 999999).ToString();

            user.ResetPasswordOtp = otp;
            user.ResetPasswordOtpExpiry = DateTime.UtcNow.AddMinutes(5);

            _unitOfWork.UserRepository.Update(user);
            await _unitOfWork.SaveChangesAsync();

            await _emailService.SendEmailAsync(user.Email, "OTP", $"Mã của bạn là: {otp}");

            return ApiResponse<bool>.Ok(true, "Đã gửi OTP");
        }

        public async Task<ApiResponse<bool>> ResetPasswordAsync(ResetPasswordRequest request)
        {
            var user = await _unitOfWork.UserRepository.FirstOrDefaultAsync(u => u.Email == request.Email);
            if (user == null)
                return ApiResponse<bool>.Fail("Tài khoản không tồn tại");

            if (user.ResetPasswordOtp != request.Otp)
                return ApiResponse<bool>.Fail("OTP không đúng");

            if (user.ResetPasswordOtpExpiry < DateTime.UtcNow)
                return ApiResponse<bool>.Fail("OTP đã hết hạn");

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            user.ResetPasswordOtp = null;
            user.ResetPasswordOtpExpiry = null;

            _unitOfWork.UserRepository.Update(user);
            await _unitOfWork.SaveChangesAsync();

            return ApiResponse<bool>.Ok(true, "Đổi mật khẩu thành công");
        }
        public async Task<ApiResponse<bool>> RegisterPartnerAsync(RegisterPartnerRequest request)
        {
            var existingPhone = await _unitOfWork.UserRepository.FirstOrDefaultAsync(u => u.Phone == request.Phone);
            if (existingPhone != null)
                return ApiResponse<bool>.Fail("Số điện thoại đã tồn tại");

            var existingEmail = await _unitOfWork.UserRepository.FirstOrDefaultAsync(u => u.Email == request.Email);
            if (existingEmail != null)
                return ApiResponse<bool>.Fail("Email đã tồn tại");

            string hashedPassword = BCrypt.Net.BCrypt.HashPassword(request.Password);

            var newUser = new User
            {
                FullName = request.OwnerName,
                Phone = request.Phone,
                Email = request.Email,
                PasswordHash = hashedPassword,
                Role = Role.StoreOwner,
                Status = UserStatus.Active
            };

            await _unitOfWork.UserRepository.AddAsync(newUser);
            await _unitOfWork.SaveChangesAsync();

            var newStore = new Store
            {
                OwnerId = newUser.Id,
                Name = request.StoreName,
                Address = request.StoreAddress,
                Description = request.StoreDescription,
                IsOpen = false,
                ApprovalStatus = ApprovalStatus.Pending
            };

            await _unitOfWork.StoreRepository.AddAsync(newStore);
            await _unitOfWork.SaveChangesAsync();

            return ApiResponse<bool>.Ok(true, "Đăng ký đối tác thành công");
        }
    }
}