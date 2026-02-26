using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.DTOs.User;
using BeautyBookingSystem.Application.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Services
{
    public class UserService : IUserService
    {
        private readonly IUnitOfWork _unitOfWork;

        public UserService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<UserProfileResponse> GetProfileAsync(string userId)
        {
            // 1. Chuyển ID từ chữ sang số
            if (!int.TryParse(userId, out int parsedUserId))
                throw new Exception("ID không hợp lệ!");

            // 2. Tìm trong Database
            var user = await _unitOfWork.UserRepository.GetByIdAsync(parsedUserId);
            if (user == null)
                throw new Exception("Không tìm thấy người dùng!");

            // 3. Đổ dữ liệu từ Database sang cái hộp DTO để trả về
            return new UserProfileResponse
            {
                Id = user.Id,
                FullName = user.FullName,
                Phone = user.Phone,
                Email = user.Email,
                AvatarUrl = user.AvatarUrl,
                Role = user.Role.ToString(),
                Status = user.Status.ToString(),
                IsPhoneVerified = user.IsPhoneVerified,
                CreatedAt = user.CreatedAt
            };
        }

        public async Task<bool> UpdateProfileAsync(string userId, UpdateProfileRequest request)
        {
            // 1. Chuyển ID sang số
            if (!int.TryParse(userId, out int parsedUserId))
                throw new Exception("ID không hợp lệ!");

            // 2. Tìm người dùng
            var user = await _unitOfWork.UserRepository.GetByIdAsync(parsedUserId);
            if (user == null)
                throw new Exception("Không tìm thấy người dùng!");

            // 3. KIỂM TRA EMAIL NGHIÊM NGẶT TRƯỚC KHI LƯU
            // Nếu khách có nhập Email mới, VÀ Email mới này khác với Email cũ của họ
            if (!string.IsNullOrWhiteSpace(request.Email) && request.Email != user.Email)
            {
                // Kiểm tra xem có ai khác trong DB đang dùng Email này chưa
                var emailInUse = await _unitOfWork.UserRepository.FirstOrDefaultAsync(u => u.Email == request.Email);
                if (emailInUse != null)
                {
                    throw new BadRequestException("Email này đã được sử dụng bởi một tài khoản khác!");
                }
            
                user.Email = request.Email;
            }
            // 3.Ghi đè thông tin mới lên thông tin cũ(Chỉ ghi đè những thứ cho phép)
            user.FullName = request.FullName;
                user.AvatarUrl = request.AvatarUrl;

            // Tự động cập nhật thời gian sửa
            user.UpdatedAt = DateTime.UtcNow;

            // 4. Lưu lại xuống Database
            _unitOfWork.UserRepository.Update(user);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }
    }
}
