using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.StoreStaff
{
    public class UpdateStaffRequest
    {
        public string FullName { get; set; } = null!;
        public string? AvatarUrl { get; set; }
        public string Position { get; set; } = null!;
        public bool IsActive { get; set; }
    }
}
