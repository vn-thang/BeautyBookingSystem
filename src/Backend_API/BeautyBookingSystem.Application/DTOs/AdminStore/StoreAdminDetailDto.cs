using BeautyBookingSystem.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.AdminStore
{
    public class StoreAdminDetailDto
    {
        public int Id { get; set; }
        public string? Name { get; set; }
        public string? Phone { get; set; }
        public string? Address { get; set; }
        public string? Description { get; set; }
        public string? AvatarUrl { get; set; }
        public string? BusinessLicenseUrl { get; set; } 

        public int OwnerId { get; set; }
        public string? OwnerName { get; set; }
        public string? OwnerEmail { get; set; }

        public ApprovalStatus Status { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
