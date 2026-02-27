using BeautyBookingSystem.Domain.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Domain.Entities
{
    public class GlobalCategory : BaseEntity
    {
        public string Name { get; set; } = string.Empty;
        public string? IconUrl { get; set; }
        public bool IsActive { get; set; }
        public int SortOrder { get; set; } = 0;

        public virtual ICollection<Service> Services { get; set; } = new List<Service>();
    }
}
