using BeautyBookingSystem.Domain.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Domain.Entities
{
    public class Staff : BaseEntity
    {
        public int StoreId { get; set; }
        public virtual Store Store { get; set; } = null!;

        public string FullName { get; set; } = string.Empty;
        public string? AvatarUrl { get; set; }
        public string? Position { get; set; }
        public bool IsActive { get; set; }

        // Navigation Properties
        public virtual ICollection<BookingDetail> BookingDetails { get; set; } = new List<BookingDetail>();
    }
}
