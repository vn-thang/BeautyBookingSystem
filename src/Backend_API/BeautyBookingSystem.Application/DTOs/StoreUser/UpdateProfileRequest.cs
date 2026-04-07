using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.StoreUser
{
    public class UpdateProfileRequest
    {
        public string FullName { get; set; } = string.Empty;

        public string? Email { get; set; }
        public string? AvatarUrl { get; set; }
        public string? FcmToken { get; set; }
    }
}
