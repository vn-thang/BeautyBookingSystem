using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.Staff
{
    public class GetAvailableStaffRequest
    {
        public int StoreId { get; set; }

        public int ServiceId { get; set; }

        public DateTime AppointmentDate { get; set; }

        public TimeSpan StartTime { get; set; }
    }
}
