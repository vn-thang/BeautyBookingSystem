using System;

namespace BeautyBookingSystem.Application.DTOs.User
{
    public class UpdateProfileRequest
    {
        public string FullName { get; set; } = string.Empty;
        public string? Email { get; set; }
        public string? AvatarUrl { get; set; }
        public string? FcmToken { get; set; }
    }
}