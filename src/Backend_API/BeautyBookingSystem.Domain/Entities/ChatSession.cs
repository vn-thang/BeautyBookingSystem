using BeautyBookingSystem.Domain.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Domain.Entities
{
    public class ChatSession : BaseEntity
    {
        public int UserId { get; set; }
        public string SessionKey { get; set; } = Guid.NewGuid().ToString("N");
        public string? Title { get; set; }

        public DateTime LastActivityAt { get; set; } = DateTime.UtcNow;

        public virtual User User { get; set; } = default!;
        public virtual ICollection<ChatMessage> Messages { get; set; } = new List<ChatMessage>();
    }
}
