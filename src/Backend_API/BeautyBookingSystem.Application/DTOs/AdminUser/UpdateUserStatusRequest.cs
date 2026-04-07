using BeautyBookingSystem.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.AdminUser
{
    public class UpdateUserStatusRequest
    {
        public UserStatus NewStatus { get; set; }
    }
}
