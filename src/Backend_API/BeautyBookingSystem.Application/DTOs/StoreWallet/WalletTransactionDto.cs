using BeautyBookingSystem.Domain.Enums;

namespace BeautyBookingSystem.Application.DTOs.StoreWallet
{
    public class WalletTransactionDto
    {
        public int Id { get; set; }
        public int? BookingId { get; set; }
        public decimal Amount { get; set; }
        public TransactionType Type { get; set; }
        public decimal BalanceBefore { get; set; }
        public decimal BalanceAfter { get; set; }
        public string Description { get; set; } = string.Empty;
        public string? Status { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}