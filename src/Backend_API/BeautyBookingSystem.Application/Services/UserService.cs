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
            if (!int.TryParse(userId, out int parsedUserId))
                throw new Exception("ID không hợp lệ!");

            var user = await _unitOfWork.UserRepository.GetByIdAsync(parsedUserId);
            if (user == null)
                throw new Exception("Không tìm thấy người dùng!");

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
            if (!int.TryParse(userId, out int parsedUserId))
                throw new Exception("ID không hợp lệ!");

            var user = await _unitOfWork.UserRepository.GetByIdAsync(parsedUserId);
            if (user == null)
                throw new Exception("Không tìm thấy người dùng!");

            if (!string.IsNullOrWhiteSpace(request.Email) && request.Email != user.Email)
            {
                var emailInUse = await _unitOfWork.UserRepository.FirstOrDefaultAsync(u => u.Email == request.Email);
                if (emailInUse != null)
                {
                    throw new BadRequestException("Email này đã được sử dụng bởi một tài khoản khác!");
                }
            
                user.Email = request.Email;
            }
            user.FullName = request.FullName;
                user.AvatarUrl = request.AvatarUrl;

            user.UpdatedAt = DateTime.UtcNow;

            _unitOfWork.UserRepository.Update(user);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }
    }
}
