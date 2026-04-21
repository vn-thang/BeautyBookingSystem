namespace BeautyBookingSystem.Application.DTOs.StoreWallet
{
    public class WalletDashboardDto
    {
        public decimal CurrentBalance { get; set; }
        public decimal MinimumBalance { get; set; }
        public bool IsOpen { get; set; }
        public decimal TotalTopUpThisMonth { get; set; }
        public decimal TotalFeeThisMonth { get; set; }
        public string? BankName { get; set; }
        public string? BankAccountNumber { get; set; }
        public string? BankAccountName { get; set; }
        public string? OwnerPhone { get; set; }
    }
}