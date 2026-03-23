using BeautyBookingSystem.Domain.Enums;

namespace BeautyBookingSystem.Application.DTOs.Voucher
{
    public class VoucherDto
    {
        public int Id { get; set; }
        public int StoreId { get; set; }

        // null => voucher áp dụng cho toàn store
        public int? ServiceId { get; set; }

        public string Code { get; set; } = string.Empty;
        public string? ImageUrl { get; set; }
        public DiscountType DiscountType { get; set; }
        public decimal DiscountValue { get; set; }
        public decimal MinOrderValue { get; set; }
        public decimal MaxDiscount { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
    }
}