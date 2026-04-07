using BeautyBookingSystem.Application.DTOs.StoreUser;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IStoreUserService
    {
        Task<UserProfileResponse> GetProfileAsync(string userId);
        Task<bool> UpdateProfileAsync(string userId, UpdateProfileRequest request);
    }
}
