using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.User
{
    public class UpdateProfileRequest
    {
        public string FullName { get; set; } = string.Empty;

        // Email và Avatar khách có thể bỏ trống (null)
        public string? Email { get; set; }
        public string? AvatarUrl { get; set; }
    }
}
