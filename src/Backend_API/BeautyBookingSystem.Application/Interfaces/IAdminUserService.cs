using BeautyBookingSystem.Application.DTOs.AdminUser;
using BeautyBookingSystem.Application.DTOs.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IAdminUserService
    {
        Task<PagedResponse<UserDto>> GetUsersAsync(UserFilterRequest request);
        Task<UserDetailDto?> GetUserByIdAsync(int id);
        Task<bool> ChangeUserStatusAsync(int id, UpdateUserStatusRequest request);
    }
}
