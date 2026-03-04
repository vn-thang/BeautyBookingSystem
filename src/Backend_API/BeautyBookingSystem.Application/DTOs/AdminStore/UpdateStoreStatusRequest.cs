using BeautyBookingSystem.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.AdminStore
{
    public class UpdateStoreStatusRequest
    {
        public ApprovalStatus NewStatus { get; set; }
    }
}
