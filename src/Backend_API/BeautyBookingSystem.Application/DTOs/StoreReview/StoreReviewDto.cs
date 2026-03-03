using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.StoreReview
{
    public class StoreReviewDto
    {
        public int Id { get; set; }
        public int BookingId { get; set; }
        public string? CustomerName { get; set; } 
        public string? CustomerAvatar { get; set; }
        public int Rating { get; set; }
        public string? Comment { get; set; }
        public string? Reply { get; set; }
        public bool IsHidden { get; set; }
    }
}
