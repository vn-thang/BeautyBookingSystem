namespace BeautyBookingSystem.Application.DTOs.StoreWallet
{
    public class WalletBalanceDto
    {
        public decimal WalletBalance { get; set; }
        public decimal MinimumBalance { get; set; }
        public bool IsLockedByDebt { get; set; }
    }
}