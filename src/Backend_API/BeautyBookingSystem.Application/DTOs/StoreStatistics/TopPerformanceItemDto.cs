
namespace BeautyBookingSystem.Application.DTOs.StoreStatistics
{
public class TopPerformanceItemDto
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public int Count { get; set; }
        public decimal Revenue { get; set; }
    }
}