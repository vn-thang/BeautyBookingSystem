using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.Chat
{
    public class ChatRequestDto
    {
        public string? SessionKey { get; set; }
        public string Message { get; set; } = string.Empty;
        public double? UserLat { get; set; }
        public double? UserLng { get; set; }
    }
}
