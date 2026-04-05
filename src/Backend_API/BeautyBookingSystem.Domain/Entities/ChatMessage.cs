using BeautyBookingSystem.Domain.Common;
using BeautyBookingSystem.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Domain.Entities
{
    public class ChatMessage : BaseEntity
    {
        public int ChatSessionId { get; set; }
        public ChatMessageRole Role { get; set; }
        public string Content { get; set; } = string.Empty;

        public string? ToolName { get; set; }
        public string? MetadataJson { get; set; }

        public virtual ChatSession ChatSession { get; set; } = default!;
    }
}
