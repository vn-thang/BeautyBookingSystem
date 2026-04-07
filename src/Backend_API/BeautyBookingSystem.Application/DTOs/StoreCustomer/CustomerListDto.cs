using System;
using System.Collections.Generic;

namespace BeautyBookingSystem.Application.DTOs.StoreCustomer
{
    public class CustomerListDto
    {
        public int CustomerId { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Phone { get; set; } = string.Empty;
        public string? AvatarUrl { get; set; }
        
        public int TotalVisits { get; set; } 
        public decimal TotalSpent { get; set; } 
    }
}