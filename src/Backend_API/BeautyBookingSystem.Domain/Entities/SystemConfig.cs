using BeautyBookingSystem.Domain.Common;

namespace BeautyBookingSystem.Domain.Entities
{
    public class SystemConfig : BaseEntity
    {
        public string Key { get; set; } = string.Empty; 
        public string Value { get; set; } = string.Empty; 
        public string? Description { get; set; } 
        public string Type { get; set; } = "string"; 
        public string Group { get; set; } = "General"; 
    }
}