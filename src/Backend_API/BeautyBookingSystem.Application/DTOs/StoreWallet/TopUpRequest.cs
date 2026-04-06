using System.ComponentModel.DataAnnotations;

namespace BeautyBookingSystem.Application.DTOs.StoreWallet
{
    public class TopUpRequest
    {
        [Required]
        public int StoreId { get; set; }

        [Required]
        [Range(1, double.MaxValue, ErrorMessage = "Số tiền nạp phải lớn hơn 0")]
        public decimal Amount { get; set; }

        public string? Note { get; set; } 
    }
}