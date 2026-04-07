using BeautyBookingSystem.Application.DTOs.User;
using System.IO;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface ICustomerUserService
    {
        Task<UserProfileResponse> GetProfileAsync(string userId);
        Task<bool> UpdateProfileAsync(string userId, UpdateProfileRequest request);
        Task<string> UpdateAvatarAsync(int userId, Stream fileStream, string fileName);
    }
}