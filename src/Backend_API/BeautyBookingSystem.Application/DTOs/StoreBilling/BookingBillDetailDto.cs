using System;
using System.Collections.Generic;

namespace BeautyBookingSystem.Application.DTOs.StoreBilling
{
    public class BookingBillDetailDto
    {
        public string StoreName { get; set; } = string.Empty;
        public string StoreAddress { get; set; } = string.Empty;
        public string StorePhone { get; set; } = string.Empty;
        public int BookingId { get; set; }
        public DateTime CreatedAt { get; set; }
        public string CustomerName { get; set; } = "Khách vãng lai";
        public string CustomerPhone { get; set; } = string.Empty;
        public List<BillServiceItemDto> Services { get; set; } = new();
        public decimal SubTotal { get; set; }      
        public decimal DiscountAmount { get; set; } 
        public decimal FinalTotal { get; set; }     
        public decimal DepositAmount { get; set; } 
        public decimal AmountToPay { get; set; }   
    }
}