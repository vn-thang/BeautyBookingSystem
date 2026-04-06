namespace BeautyBookingSystem.Application.DTOs.SystemContent
{
    public class UpdateSystemContentRequest
    {
        public string Title { get; set; } = string.Empty;
        public string Content { get; set; } = string.Empty;
        public bool IsActive { get; set; }
    }
}