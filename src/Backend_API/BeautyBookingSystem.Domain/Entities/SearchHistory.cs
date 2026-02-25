using BeautyBookingSystem.Domain.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Domain.Entities
{
    public class SearchHistory : BaseEntity
    {
        public int CustomerId { get; set; }
        public virtual User Customer { get; set; } = null!;

        public string Keyword { get; set; } = string.Empty;
    }
}
