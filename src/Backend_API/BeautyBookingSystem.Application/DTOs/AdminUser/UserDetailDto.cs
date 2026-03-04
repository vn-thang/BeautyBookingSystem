using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.AdminUser
{
    public class UserDetailDto : UserDto
    {
        public bool IsPhoneVerified { get; set; }
        public int TotalBookings { get; set; }
        public int TotalStores { get; set; }   
        public int TotalReviews { get; set; }
    }
}
