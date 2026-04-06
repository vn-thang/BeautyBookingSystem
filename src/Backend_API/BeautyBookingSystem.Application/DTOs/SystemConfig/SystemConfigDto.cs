namespace BeautyBookingSystem.Application.DTOs.SystemConfig
{
    public class SystemConfigDto
    {
        public int Id { get; set; }
        public string Key { get; set; } = null!;
        public string Value { get; set; } = null!;
        public string Type { get; set; } = null!; 
        public string Group { get; set; } = null!;
        public string? Description { get; set; }
    }
}