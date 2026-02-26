using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.Auth
{
    public class LoginRequest
    {
        public string EmailOrPhone { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
    }
}
