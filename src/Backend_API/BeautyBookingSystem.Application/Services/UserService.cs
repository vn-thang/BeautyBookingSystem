using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.DTOs.User;
using BeautyBookingSystem.Application.Interfaces;

namespace BeautyBookingSystem.Application.Services
{
    public class UserService : IUserService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICloudinaryService _cloudinaryService;

        public UserService(IUnitOfWork unitOfWork, ICloudinaryService cloudinaryService)
        {
            _unitOfWork = unitOfWork;
            _cloudinaryService = cloudinaryService;
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
                if (emailInUse != null && emailInUse.Id != user.Id)
                    throw new BadRequestException("Email này đã được sử dụng bởi một tài khoản khác!");

                user.Email = request.Email;
            }

            if (!string.IsNullOrWhiteSpace(request.FullName))
                user.FullName = request.FullName;

            if (!string.IsNullOrWhiteSpace(request.AvatarUrl))
                user.AvatarUrl = request.AvatarUrl;

            if (!string.IsNullOrWhiteSpace(request.FcmToken))
                user.FcmToken = request.FcmToken;

            user.UpdatedAt = DateTime.UtcNow;

            _unitOfWork.UserRepository.Update(user);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<string> UpdateAvatarAsync(int userId, Stream fileStream, string fileName)
        {
            var imageUrl = await _cloudinaryService.UploadImageAsync(fileStream, fileName);

            if (string.IsNullOrWhiteSpace(imageUrl))
                throw new Exception("Upload ảnh thất bại!");

            var user = await _unitOfWork.UserRepository.GetByIdAsync(userId);
            if (user == null)
                throw new Exception("User not found");

            user.AvatarUrl = imageUrl;
            user.UpdatedAt = DateTime.UtcNow;

            _unitOfWork.UserRepository.Update(user);
            await _unitOfWork.SaveChangesAsync();

            return imageUrl;
        }
    }
}