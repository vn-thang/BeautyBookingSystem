using System.Collections.Generic;

namespace BeautyBookingSystem.Application.DTOs.StoreStaff
{
    public class UpdateStaffScheduleWrapperRequest
    {
        public List<UpdateStaffScheduleRequest> Schedules { get; set; } = new List<UpdateStaffScheduleRequest>();
    }
}