using BeautyBookingSystem.Domain.Common;
using System;

namespace BeautyBookingSystem.Domain.Entities
{
    public class StaffSchedule : BaseEntity
    {
        public int StaffId { get; set; }
        public DayOfWeek DayOfWeek { get; set; } 
        public TimeSpan StartTime { get; set; }
        public TimeSpan EndTime { get; set; }
        public bool IsWorking { get; set; }

        public virtual Staff Staff { get; set; } = null!;
    }
}