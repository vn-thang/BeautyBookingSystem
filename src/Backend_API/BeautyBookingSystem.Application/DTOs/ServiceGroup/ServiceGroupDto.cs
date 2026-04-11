namespace BeautyBookingSystem.Application.DTOs.ServiceGroup
{
    public class ServiceGroupDto
    {
        public int Id { get; set; }
        public int StoreId { get; set; }
        public string Name { get; set; } = null!;
        public int SortOrder { get; set; }
    }
}