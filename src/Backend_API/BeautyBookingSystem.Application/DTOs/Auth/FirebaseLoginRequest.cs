namespace BeautyBookingSystem.Application.DTOs.Auth
{
    public class FirebaseLoginRequest
    {
        public string IdToken { get; set; } = string.Empty; 
        public string? FcmToken { get; set; } 
        public bool LinkToExistingAccount { get; set; } = false;
        public bool IsStoreOwnerApp { get; set; } = false;
    }
}