using BeautyBookingSystem.Domain.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Domain.Entities
{
    public class CustomerFavorite : BaseEntity
    {
        public int CustomerId { get; set; }
        public virtual User Customer { get; set; } = null!;

        public int? StoreId { get; set; }
        public virtual Store? Store { get; set; }

        public int? ServiceId { get; set; }
        public virtual Service? Service { get; set; }
    }
}
