using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.StoreDashboard
{
    public class BookingCountsDto
    {
        public int Pending { get; set; }     
        public int Confirmed { get; set; }    
        public int Completed { get; set; }  
        public int CancelledByCustomer { get; set; } 
    }
}
