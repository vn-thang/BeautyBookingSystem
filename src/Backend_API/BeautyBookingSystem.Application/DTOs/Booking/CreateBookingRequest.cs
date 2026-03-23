using BeautyBookingSystem.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.Booking
{
    public class CreateBookingRequest
    {
        public int StoreId { get; set; }

        public int? VoucherId { get; set; }

        public string? CustomerNote { get; set; }

        public PaymentMethod PaymentMethod { get; set; }
        public decimal DepositAmount { get; set; }

        public List<CreateBookingDetailRequest> Services { get; set; } = new();
    }
}
