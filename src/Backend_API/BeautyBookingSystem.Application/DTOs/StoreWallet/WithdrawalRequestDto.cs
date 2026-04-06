namespace BeautyBookingSystem.Application.DTOs.StoreWallet
{
    public class WithdrawalRequestDto
    {
        public int Id { get; set; }
        public int StoreId { get; set; }
        public string StoreName { get; set; } = string.Empty; 
        public decimal Amount { get; set; }
        public string BankName { get; set; } = string.Empty;
        public string BankAccountNumber { get; set; } = string.Empty;
        public string BankAccountName { get; set; } = string.Empty;
        public int Status { get; set; } 
        public string? AdminNote { get; set; }
        public string? ReceiptImageUrl { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? ProcessedAt { get; set; }
    }
}