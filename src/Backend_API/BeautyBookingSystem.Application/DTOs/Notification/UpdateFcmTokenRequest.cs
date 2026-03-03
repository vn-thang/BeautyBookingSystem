using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.Notification
{
    public class UpdateFcmTokenRequest
    {
        [Required(ErrorMessage = "FCM Token không được để trống")]
        public string FcmToken { get; set; } = string.Empty;
    }
}
