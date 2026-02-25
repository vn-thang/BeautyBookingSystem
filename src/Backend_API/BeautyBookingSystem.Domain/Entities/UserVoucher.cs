using BeautyBookingSystem.Domain.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Domain.Entities
{
    public class UserVoucher : BaseEntity
    {
        public int CustomerId { get; set; }
        public virtual User Customer { get; set; } = null!;

        public int VoucherId { get; set; }
        public virtual Voucher Voucher { get; set; } = null!;

        public bool IsUsed { get; set; }
        public DateTime CollectedAt { get; set; } = DateTime.UtcNow;
    }
}
