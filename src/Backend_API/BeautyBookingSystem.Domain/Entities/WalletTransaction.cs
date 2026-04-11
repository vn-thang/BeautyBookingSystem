using BeautyBookingSystem.Domain.Common;
using BeautyBookingSystem.Domain.Enums;

namespace BeautyBookingSystem.Domain.Entities
{
    public class WalletTransaction : BaseEntity
    {
        public int StoreId { get; set; }
        public virtual Store Store { get; set; } = null!;

        public int? BookingId { get; set; }
        public virtual Booking? Booking { get; set; }

        public decimal Amount { get; set; } 
        public TransactionType Type { get; set; } 
        public decimal BalanceBefore { get; set; }
        public decimal BalanceAfter { get; set; }
        public string Description { get; set; } = string.Empty;
        public TransactionStatus Status { get; set; } 
    }
}