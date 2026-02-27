using BeautyBookingSystem.Domain.Common;
using BeautyBookingSystem.Domain.Enums;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Domain.Entities
{
    public class Store : BaseEntity
    {
        public int OwnerId { get; set; }
        public virtual User Owner { get; set; } = null!;

        public string Name { get; set; } = string.Empty;
        public string Address { get; set; } = string.Empty;
        public string Phone { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? LogoUrl { get; set; }
        public string? CoverImageUrl { get; set; }

        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
        public bool IsOpen { get; set; }
        public ApprovalStatus ApprovalStatus { get; set; }

        // Navigation Properties
        public virtual ICollection<StoreOperatingHour> OperatingHours { get; set; } = new List<StoreOperatingHour>();
        public virtual ICollection<Staff> Staffs { get; set; } = new List<Staff>();
        public virtual ICollection<ServiceGroup> ServiceGroups { get; set; } = new List<ServiceGroup>();
        public virtual ICollection<Service> Services { get; set; } = new List<Service>();
        public virtual ICollection<Voucher> Vouchers { get; set; } = new List<Voucher>();
        public virtual ICollection<Booking> Bookings { get; set; } = new List<Booking>();
        public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();
    }
}
