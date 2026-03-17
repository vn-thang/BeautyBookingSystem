using System;
using System.Collections.Generic;

namespace BeautyBookingSystem.Application.DTOs.StoreCustomer
{
    // 1. DTO cho Danh sách khách hàng ngoài màn hình chính
    public class CustomerListDto
    {
        public int CustomerId { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Phone { get; set; } = string.Empty;
        public string? AvatarUrl { get; set; }
        
        public int TotalVisits { get; set; } // Tổng số lần đã đến (Completed)
        public decimal TotalSpent { get; set; } // Tổng tiền đã chi tiêu
    }
}