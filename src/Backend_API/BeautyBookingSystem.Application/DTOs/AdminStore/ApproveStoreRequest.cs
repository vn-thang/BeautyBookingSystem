using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.AdminStore
{
    public class ApproveStoreRequest
    {
        public bool IsApproved { get; set; } 
        public string? Remarks { get; set; } 
    }
}
