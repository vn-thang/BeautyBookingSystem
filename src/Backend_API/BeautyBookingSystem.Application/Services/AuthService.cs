using AutoMapper;
using BeautyBookingSystem.Application.Common.Exceptions; 
using BeautyBookingSystem.Application.DTOs.Auth;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.EntityFrameworkCore; 
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
        private readonly IMapper _mapper;

        public AuthService(IConfiguration config, IUnitOfWork unitOfWork, IEmailService emailService, IMapper mapper)
        {
            _config = config;
            _unitOfWork = unitOfWork;
            _emailService = emailService;
            _mapper = mapper;
        }
        public async Task<TokenResponse> RegisterAsync(RegisterRequest request)
        {

            await CheckDuplicateUserAsync(request.Phone, request.Email);

            var newUser = _mapper.Map<User>(request);

            newUser.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password).Trim();
            newUser.Role = Role.Customer;
            newUser.Status = UserStatus.Active;

            await _unitOfWork.UserRepository.AddAsync(newUser);
            await _unitOfWork.SaveChangesAsync();

            return await GenerateTokensAndUpdateUserAsync(newUser);
        }

        public async Task<TokenResponse> LoginAsync(LoginRequest request)
        {
            var user = await _unitOfWork.UserRepository.FirstOrDefaultAsync(
                u => u.Phone == request.EmailOrPhone || u.Email == request.EmailOrPhone);

            if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
                throw new BadRequestException("Số điện thoại/Email hoặc mật khẩu không đúng.");

            if (user.Status != UserStatus.Active)
                throw new BadRequestException("Tài khoản của bạn đã bị khóa.");
            if (!string.IsNullOrEmpty(request.FcmToken))
            {
                user.FcmToken = request.FcmToken;
            }

            return await GenerateTokensAndUpdateUserAsync(user);
        }

        public async Task<TokenResponse> RefreshTokenAsync(RefreshTokenRequest request)
        {
            var principal = GetPrincipalFromExpiredToken(request.AccessToken);
            if (principal == null) throw new BadRequestException("Access Token không hợp lệ.");

            var userIdString = principal.Claims.FirstOrDefault(c => c.Type == JwtRegisteredClaimNames.Sub)?.Value;
            if (!int.TryParse(userIdString, out int userId)) throw new BadRequestException("Dữ liệu Token bị lỗi.");

            var user = await _unitOfWork.UserRepository.GetByIdAsync(userId);
            if (user == null || user.RefreshToken != request.RefreshToken || user.RefreshTokenExpiryTime <= DateTime.UtcNow)
            {
                throw new BadRequestException("Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.");
            }

            return await GenerateTokensAndUpdateUserAsync(user);
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
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new Claim(ClaimTypes.Name, user.FullName),
                new Claim(ClaimTypes.MobilePhone, user.Phone),
                new Claim(ClaimTypes.Role, user.Role.ToString())
            };

            
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]!));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha512Signature);

            var token = new JwtSecurityToken(
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

            if (securityToken is not JwtSecurityToken jwtSecurityToken || !jwtSecurityToken.Header.Alg.Equals(SecurityAlgorithms.HmacSha512, StringComparison.InvariantCultureIgnoreCase))
                throw new SecurityTokenException("Token không đúng định dạng chữ ký");

            return principal;
        }
        
        public async Task<bool> ChangePasswordAsync(string userId, ChangePasswordRequest request)
        {

            var user = await GetUserByIdAsync(userId);

            bool isOldPasswordCorrect = BCrypt.Net.BCrypt.Verify(request.OldPassword, user.PasswordHash);
            if (!isOldPasswordCorrect)
            {
                throw new Exception("Mật khẩu cũ không chính xác!");
            }

            string hashedNewPassword = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);

            user.PasswordHash = hashedNewPassword;
            _unitOfWork.UserRepository.Update(user);

            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<bool> LogoutAsync(string userId)
        {
            var user = await GetUserByIdAsync(userId);

            user.RefreshToken = null;
            user.RefreshTokenExpiryTime = null; 

           
            _unitOfWork.UserRepository.Update(user);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<bool> ForgotPasswordAsync(ForgotPasswordRequest request)
        {
            var user = await _unitOfWork.UserRepository.FirstOrDefaultAsync(u => u.Email == request.Email);
            if (user == null)
            {
                throw new BadRequestException("Email này chưa được đăng ký trong hệ thống!");
            }

            string otp = new Random().Next(100000, 999999).ToString();

            user.ResetPasswordOtp = otp;
            user.ResetPasswordOtpExpiry = DateTime.UtcNow.AddMinutes(5);

            _unitOfWork.UserRepository.Update(user);
            await _unitOfWork.SaveChangesAsync();

            string subject = "Mã xác nhận khôi phục mật khẩu - Beauty Booking";
            string body = $@"
            <div style='font-family: Arial, sans-serif; padding: 20px;'>
            <h2>Khôi phục mật khẩu</h2>
            <p>Chào bạn,</p>
            <p>Mã OTP để đặt lại mật khẩu của bạn là:</p>
            <h1 style='color: #d9534f; font-size: 32px; letter-spacing: 5px;'>{otp}</h1>
            <p>Mã này sẽ hết hạn sau <b>5 phút</b>. Tuyệt đối không chia sẻ mã này cho người khác.</p>
            </div>";

            await _emailService.SendEmailAsync(user.Email, subject, body);
            return true;
        }

        public async Task<bool> ResetPasswordAsync(ResetPasswordRequest request)
        {
            var user = await _unitOfWork.UserRepository.FirstOrDefaultAsync(u => u.Email == request.Email);
            if (user == null)
                throw new BadRequestException("Tài khoản không tồn tại!");

            if (user.ResetPasswordOtp != request.Otp)
                throw new BadRequestException("Mã OTP không chính xác!");

            if (user.ResetPasswordOtpExpiry < DateTime.UtcNow)
                throw new BadRequestException("Mã OTP đã hết hạn. Vui lòng yêu cầu mã mới!");

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            // 4. XÓA MÃ OTP SAU KHI DÙNG XONG 
            user.ResetPasswordOtp = null;
            user.ResetPasswordOtpExpiry = null;
            user.RefreshToken = null;
            user.RefreshTokenExpiryTime = null;

            _unitOfWork.UserRepository.Update(user);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }
        public async Task<bool> RegisterPartnerAsync(RegisterPartnerRequest request)
        {
            await CheckDuplicateUserAsync(request.Phone, request.Email);

            var newUser = _mapper.Map<User>(request);
            newUser.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);
            newUser.Role = Role.StoreOwner;
            newUser.Status = UserStatus.Active;

            await _unitOfWork.UserRepository.AddAsync(newUser);
            await _unitOfWork.SaveChangesAsync(); 

            var newStore = _mapper.Map<Store>(request);
            newStore.OwnerId = newUser.Id;
            newStore.IsOpen = false;
            newStore.ApprovalStatus = ApprovalStatus.Pending;

            await _unitOfWork.StoreRepository.AddAsync(newStore);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }
        private async Task CheckDuplicateUserAsync(string phone, string email)
        {
            bool isPhoneExist = await _unitOfWork.UserRepository.GetQueryable().AnyAsync(u => u.Phone == phone);
            if (isPhoneExist) throw new BadRequestException("Số điện thoại này đã được đăng ký!");

            bool isEmailExist = await _unitOfWork.UserRepository.GetQueryable().AnyAsync(u => u.Email == email);
            if (isEmailExist) throw new BadRequestException("Email này đã được sử dụng cho một tài khoản khác!");
        }

        private async Task<User> GetUserByIdAsync(string userId)
        {
            if (!int.TryParse(userId, out int parsedUserId))
                throw new BadRequestException("ID người dùng từ Token không hợp lệ!");

            var user = await _unitOfWork.UserRepository.GetByIdAsync(parsedUserId);
            if (user == null)
                throw new NotFoundException("Không tìm thấy người dùng!");

            return user;
        }
    }
}