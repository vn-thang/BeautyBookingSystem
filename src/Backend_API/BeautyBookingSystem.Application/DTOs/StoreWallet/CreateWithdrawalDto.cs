namespace BeautyBookingSystem.Application.DTOs.StoreWallet
{
public class CreateWithdrawalDto
    {
        public decimal Amount { get; set; }
         public string FirebaseIdToken { get; set; } = string.Empty;
    }
}