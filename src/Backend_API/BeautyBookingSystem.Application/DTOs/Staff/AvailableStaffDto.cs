using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.Staff
{
    public class AvailableStaffDto
    {
        public int Id { get; set; }

        public string Name { get; set; } = "";

        public string? AvatarUrl { get; set; }
    }
}
