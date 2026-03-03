using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.StoreBooking
{
    public class AssignStaffRequest
    {
        public List<StaffAssignmentItem> Assignments { get; set; } = new();
    }
}
