using BeautyBookingSystem.Domain.Enums;

namespace BeautyBookingSystem.Application.DTOs.Voucher
{
    public class ServiceVoucherHomeDto
    {
        public int Id { get; set; }
        public int StoreId { get; set; }
        public int? ServiceId { get; set; }
        public string Code { get; set; } = string.Empty;
        public string? ImageUrl { get; set; }

        public string ServiceName { get; set; } = string.Empty;

        public decimal OriginalPrice { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal DiscountedPrice { get; set; }

        public DiscountType DiscountType { get; set; }
        public decimal DiscountValue { get; set; }
        public decimal MinOrderValue { get; set; }
        public decimal MaxDiscount { get; set; }

        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
    }
}