using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.StoreBooking
{
    public class UpdateBookingStatusRequest
    {
        public string Status { get; set; } = string.Empty;
        public string? CancelReason { get; set; } 
    }
}
