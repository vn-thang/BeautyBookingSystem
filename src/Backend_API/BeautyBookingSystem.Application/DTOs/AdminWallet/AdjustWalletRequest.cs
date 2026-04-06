using BeautyBookingSystem.Domain.Enums;

namespace BeautyBookingSystem.Application.DTOs.AdminWallet
{
    public class AdjustWalletRequest
    {
        public decimal Amount { get; set; } 
        public TransactionType Type { get; set; } 
        public string Reason { get; set; } = null!; 
    }
}