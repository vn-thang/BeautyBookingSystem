using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.StoreBooking
{
    public class StoreBookingDetailDto : StoreBookingListDto
    {
        public string? CustomerNote { get; set; } 
        public decimal TotalPrice { get; set; }
        public decimal DiscountAmount { get; set; }
        public string? CancelReason { get; set; } 
        public string? CancelledBy { get; set; }  
        public List<BookingServiceItemDto> Services { get; set; } = new();
    }
}
