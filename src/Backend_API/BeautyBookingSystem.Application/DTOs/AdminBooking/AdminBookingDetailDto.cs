using BeautyBookingSystem.Domain.Enums;
using System;
using System.Collections.Generic;

namespace BeautyBookingSystem.Application.DTOs.AdminBooking
{
    public class AdminBookingDetailDto : AdminBookingListDto
    {
        public decimal TotalPrice { get; set; }
        public decimal DiscountAmount { get; set; }
        public decimal DepositAmount { get; set; } 
        public decimal RemainingAmount { get; set; } 
        public string? PaymentMethod { get; set; }
        public string? CustomerNote { get; set; }
        public string? CancelReason { get; set; }
        public CancelledByType? CancelledBy { get; set; }
        
        public List<AdminBookingDetailItemDto> Services { get; set; } = new List<AdminBookingDetailItemDto>();
    }
}