using BeautyBookingSystem.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.AdminStore
{
    public class StoreAdminDto
    {
        public int Id { get; set; }
        public string? Name { get; set; }
        public string? Phone { get; set; }
        public string? OwnerName { get; set; }
        public ApprovalStatus Status { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
