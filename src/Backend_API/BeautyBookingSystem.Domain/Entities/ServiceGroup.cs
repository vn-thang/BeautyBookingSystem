using BeautyBookingSystem.Domain.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Domain.Entities
{
    public class ServiceGroup : BaseEntity
    {
        public int StoreId { get; set; }
        public virtual Store Store { get; set; } = null!;

        public string Name { get; set; } = string.Empty;

        public virtual ICollection<Service> Services { get; set; } = new List<Service>();
    }
}
