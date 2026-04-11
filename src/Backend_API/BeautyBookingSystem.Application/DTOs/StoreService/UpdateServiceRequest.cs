using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.StoreService
{
    public class UpdateServiceRequest : CreateServiceRequest
    {
        public bool IsActive { get; set; }
    }
}
