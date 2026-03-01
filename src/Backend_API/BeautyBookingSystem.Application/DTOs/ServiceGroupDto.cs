namespace BeautyBookingSystem.Application.DTOs
{
    public class ServiceGroupDto
    {
        public int Id { get; set; }
        public int StoreId { get; set; }
        public string Name { get; set; } = string.Empty;
    }
}