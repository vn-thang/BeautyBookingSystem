using BeautyBookingSystem.Domain.Common;
using System;

namespace BeautyBookingSystem.Domain.Entities
{
    public class StaffLeave : BaseEntity
    {
        public int StaffId { get; set; }
        public DateTime FromDate { get; set; }
        public DateTime ToDate { get; set; }
        public string? Reason { get; set; }

        public virtual Staff Staff { get; set; } = null!;
    }
}