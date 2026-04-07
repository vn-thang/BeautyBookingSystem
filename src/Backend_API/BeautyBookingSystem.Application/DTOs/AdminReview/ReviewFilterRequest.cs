using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.AdminReview
{
    public class ReviewFilterRequest 
    {
        public int PageIndex { get; set; } = 1; 
        public int PageSize { get; set; } = 10; 
        public int? StoreId { get; set; }
        public int? Rating { get; set; }
        public bool? IsHidden { get; set; }
        public string? SearchTerm { get; set; } 
    }
}
