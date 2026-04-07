using BeautyBookingSystem.Domain.Enums;

namespace BeautyBookingSystem.Application.DTOs.AdminWallet
{
    public class AdminWalletTransactionDto
    {
        public int Id { get; set; }
        public int StoreId { get; set; }
        public string StoreName { get; set; } = null!; 
        public decimal Amount { get; set; }
        public TransactionType Type { get; set; }
        public string TypeName => Type.ToString(); 
        public decimal BalanceBefore { get; set; }
        public decimal BalanceAfter { get; set; }
        public string? Description { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}