using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.Chat
{
    public class ChatResponseDto
    {
        public string SessionKey { get; set; } = string.Empty;
        public string Reply { get; set; } = string.Empty;
    }
}
