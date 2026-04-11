namespace BeautyBookingSystem.Application.DTOs.StoreStaff
{
    public class StaffScheduleDto
    {
        public int Id { get; set; }
        public int StaffId { get; set; }
        public DayOfWeek DayOfWeek { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
        public bool IsWorking { get; set; }
    }
}