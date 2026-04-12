using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.Booking
{
    public class GetAvailableTimeSlotsRequest
    {
        public int StoreId { get; set; }
        public DateTime Date { get; set; }
        public List<int> ServiceIds { get; set; } = new();
        public int? ExcludeBookingId { get; set; }
    }
}
