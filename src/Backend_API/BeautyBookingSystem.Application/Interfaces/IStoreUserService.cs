
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BeautyBookingSystem.Application.DTOs.StoreUser;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IStoreUserService
    {
        Task<StoreUserProfileResponse> GetProfileAsync(string userId);
        Task<bool> UpdateProfileAsync(string userId, StoreUpdateProfileRequest request);
    }
}
