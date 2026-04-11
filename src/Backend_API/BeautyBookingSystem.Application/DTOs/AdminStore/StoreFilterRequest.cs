using BeautyBookingSystem.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.AdminStore
{
    // 1. Request dùng để lọc và phân trang danh sách Store
    public class StoreFilterRequest
    {
        public int PageIndex { get; set; } = 1;
        public int PageSize { get; set; } = 10;
        public string? SearchTerm { get; set; } 
        public ApprovalStatus? Status { get; set; } 
        public bool? IsDebt { get; set; }
    }
}
