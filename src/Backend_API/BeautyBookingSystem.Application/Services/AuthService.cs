using BeautyBookingSystem.Application.Common.Exceptions; // Nơi chứa BadRequestException
using BeautyBookingSystem.Application.DTOs.Auth;
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

        // --- 1. HÀM ĐĂNG KÝ ---
        public async Task<TokenResponse> RegisterAsync(RegisterRequest request)
        {
            // Dùng thống nhất qua _unitOfWork
            var existingUser = await _unitOfWork.UserRepository.FirstOrDefaultAsync(u => u.Phone == request.Phone);
            if (existingUser != null)
                throw new BadRequestException("Số điện thoại này đã được đăng ký.");

            var existingEmail = await _unitOfWork.UserRepository.FirstOrDefaultAsync(u => u.Email == request.Email);
            if (existingEmail != null)
            {
                throw new BadRequestException("Email này đã được sử dụng cho một tài khoản khác!");
            }

            string hashedPassword = BCrypt.Net.BCrypt.HashPassword(request.Password);

            var newUser = new User
            {
                FullName = request.FullName,
                Phone = request.Phone.Trim(),
                Email = request.Email.Trim(),
                PasswordHash = hashedPassword.Trim(),
                Role = Role.Customer,
                Status = UserStatus.Active
            };

            await _unitOfWork.UserRepository.AddAsync(newUser);
            await _unitOfWork.SaveChangesAsync();

            return await GenerateTokensAndUpdateUserAsync(newUser);
        }

        // --- 2. HÀM ĐĂNG NHẬP ---
        public async Task<TokenResponse> LoginAsync(LoginRequest request)
        {
            // TÌM KIẾM BẰNG CẢ 2 CỘT: Phone HOẶC Email
            var user = await _unitOfWork.UserRepository.FirstOrDefaultAsync(
                u => u.Phone == request.EmailOrPhone || u.Email == request.EmailOrPhone);

            //if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            //    throw new BadRequestException("Số điện thoại/Email hoặc mật khẩu không đúng.");
            if (user == null)
            {
                // Cố tình in thẳng giá trị mà C# nhận được từ Postman ra màn hình
                throw new BadRequestException($"LỖI 1: Hệ thống tìm không thấy. C# đang đi tìm chuỗi này: '{request.EmailOrPhone}'");
            }

            // 3. Bắt lỗi SAI MẬT KHẨU
            bool isPasswordValid = BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash);
            if (!isPasswordValid)
            {
                throw new BadRequestException("LỖI 2: Tìm thấy người rồi, nhưng mật khẩu bị sai!");
            }

            if (user.Status != UserStatus.Active)
                throw new BadRequestException("Tài khoản của bạn đã bị khóa.");

            return await GenerateTokensAndUpdateUserAsync(user);
        }

        // --- 3. HÀM LÀM MỚI TOKEN ---
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
            var refreshToken = CreateRefreshToken(); // Random 1 chuỗi ngẫu nhiên

            // Cập nhật RefreshToken mới vào DB để lần sau so sánh
            user.RefreshToken = refreshToken;
            user.RefreshTokenExpiryTime = DateTime.UtcNow.AddDays(7); // Hạn 7 ngày

            _unitOfWork.UserRepository.Update(user);
            await _unitOfWork.SaveChangesAsync();

            return new TokenResponse { AccessToken = accessToken, RefreshToken = refreshToken };
        }

        private string CreateAccessToken(User user)
        {
            // Nhét thông tin user vào bên trong Token (gọi là Claims)
            var claims = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new Claim(ClaimTypes.Name, user.FullName),
                new Claim(ClaimTypes.MobilePhone, user.Phone),
                new Claim(ClaimTypes.Role, user.Role.ToString())
            };

            // Dùng khóa bí mật trong appsettings.json để ký xác nhận
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]!));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha512Signature);

            var token = new JwtSecurityToken(
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(15), // Hạn 15 phút
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }

        private string CreateRefreshToken()
        {
            var randomNumber = new byte[32];
            using var rng = RandomNumberGenerator.Create();
            rng.GetBytes(randomNumber); //Fill dữ liệu ngẫu nhiên vào mảng byte.
            return Convert.ToBase64String(randomNumber); //Byte không đọc được → convert sang string.
        }

        private ClaimsPrincipal? GetPrincipalFromExpiredToken(string token)
        {
            var tokenValidationParameters = new TokenValidationParameters
            {
                ValidateAudience = false,
                ValidateIssuer = false,
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"]!)),
                ValidateLifetime = false // Quan trọng: Cho phép đọc token dù đã hết 15 phút
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var principal = tokenHandler.ValidateToken(token, tokenValidationParameters, out SecurityToken securityToken);

            if (securityToken is not JwtSecurityToken jwtSecurityToken || !jwtSecurityToken.Header.Alg.Equals(SecurityAlgorithms.HmacSha512, StringComparison.InvariantCultureIgnoreCase))
                throw new SecurityTokenException("Token không đúng định dạng chữ ký");

            return principal;
        }
        
        public async Task<bool> ChangePasswordAsync(string userId, ChangePasswordRequest request)
        {
            // 1. Tìm user trong Database dựa vào ID. 
            if (!int.TryParse(userId, out int parsedUserId))
            {
                throw new Exception("ID người dùng từ Token không hợp lệ!");
            }

            // 2. Truyền cái số (parsedUserId) vừa ép kiểu xong vào cho kho tìm kiếm
            var user = await _unitOfWork.UserRepository.GetByIdAsync(parsedUserId);
            if (user == null)
            {
                throw new Exception("Không tìm thấy người dùng!");
            }

            // 2. Kiểm tra xem Mật khẩu cũ khách nhập có khớp với mật khẩu đã băm (Hash) trong DB không
            // Hàm Verify của BCrypt sẽ tự động so sánh chuỗi thô (OldPassword) với chuỗi loằng ngoằng trong DB.
            bool isOldPasswordCorrect = BCrypt.Net.BCrypt.Verify(request.OldPassword, user.PasswordHash);
            if (!isOldPasswordCorrect)
            {
                throw new Exception("Mật khẩu cũ không chính xác!");
            }

            // 3. Nếu đúng rồi, tiến hành băm (Hash) Mật khẩu mới
            string hashedNewPassword = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);

            // 4. Cập nhật lại mật khẩu mới cho user
            user.PasswordHash = hashedNewPassword;
            _unitOfWork.UserRepository.Update(user);

            // 5. Lưu xuống Database
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<bool> LogoutAsync(string userId)
        {
            // 1. Ép kiểu ID giống hệt lúc làm ChangePassword
            if (!int.TryParse(userId, out int parsedUserId))
            {
                throw new Exception("ID người dùng từ Token không hợp lệ!");
            }

            // 2. Tìm User trong Database
            var user = await _unitOfWork.UserRepository.GetByIdAsync(parsedUserId);
            if (user == null)
            {
                return false;
            }

            // 3. "Tiêu diệt" Refresh Token bằng cách gán nó thành null (hoặc chuỗi rỗng)
            user.RefreshToken = null;
            user.RefreshTokenExpiryTime = null; 

           
            _unitOfWork.UserRepository.Update(user);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<bool> ForgotPasswordAsync(ForgotPasswordRequest request)
        {
            // 1. Tìm xem Email này có trong hệ thống không
            var user = await _unitOfWork.UserRepository.FirstOrDefaultAsync(u => u.Email == request.Email);
            if (user == null)
            {
                throw new BadRequestException("Email này chưa được đăng ký trong hệ thống!");
            }

            string otp = new Random().Next(100000, 999999).ToString();

            // 3. Lưu OTP và thời gian hết hạn (Cho phép sống đúng 5 phút) vào Database
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
    }
}