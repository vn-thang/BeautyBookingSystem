using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BeautyBookingSystem.Domain.Common;
using BeautyBookingSystem.Domain.Enums;

namespace BeautyBookingSystem.Domain.Entities
{
    public class User : BaseEntity
    {
        public string FullName { get; set; } = string.Empty;
        public string Phone { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? AvatarUrl { get; set; }
        public string PasswordHash { get; set; } = string.Empty;

        public Role Role { get; set; }
        public UserStatus Status { get; set; }
        public bool IsPhoneVerified { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? UpdatedAt { get; set; }
        public string? RefreshToken { get; set; }
        public DateTime? RefreshTokenExpiryTime { get; set; }

        public string? ResetPasswordOtp { get; set; }
        public DateTime? ResetPasswordOtpExpiry { get; set; }

        // Navigation Properties (Các bảng liên kết với User)
        public virtual ICollection<Store> Stores { get; set; } = new List<Store>();
        public virtual ICollection<Booking> Bookings { get; set; } = new List<Booking>();
        public virtual ICollection<UserVoucher> UserVouchers { get; set; } = new List<UserVoucher>();
        public virtual ICollection<CustomerFavorite> Favorites { get; set; } = new List<CustomerFavorite>();
        public virtual ICollection<SearchHistory> SearchHistories { get; set; } = new List<SearchHistory>();
        public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();
        public virtual ICollection<Notification> Notifications { get; set; } = new List<Notification>();
    }
}
