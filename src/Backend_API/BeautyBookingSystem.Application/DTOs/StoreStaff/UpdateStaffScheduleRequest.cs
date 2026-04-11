using System.ComponentModel.DataAnnotations;

namespace BeautyBookingSystem.Application.DTOs.StoreStaff
{
public class UpdateStaffScheduleRequest
    {
        [Required]
        public DayOfWeek DayOfWeek { get; set; }
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
        public bool IsWorking { get; set; }
    }
}