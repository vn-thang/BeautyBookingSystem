using BeautyBookingSystem.Domain.Common;
using BeautyBookingSystem.Domain.Enums;

namespace BeautyBookingSystem.Domain.Entities
{
    public class WithdrawalRequest : BaseEntity
    {
        public int StoreId { get; set; }
        public virtual Store Store { get; set; } = null!;

        public decimal Amount { get; set; } 
        public string BankName { get; set; } = string.Empty; 
        public string BankAccountNumber { get; set; } = string.Empty;
        public string BankAccountName { get; set; } = string.Empty;

        public WithdrawalStatus Status { get; set; } = WithdrawalStatus.Pending;
    
        public string? AdminNote { get; set; } 
        public string? ReceiptImageUrl { get; set; } 
        public int? ProcessedByAdminId { get; set; } 
        public DateTime? ProcessedAt { get; set; } 
    }
}