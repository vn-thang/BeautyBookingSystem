using BeautyBookingSystem.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.Booking
{
    public class BookingResponseDto
    {
        public int Id { get; set; }

        public decimal TotalPrice { get; set; }

        public decimal DiscountAmount { get; set; }

        public decimal FinalPrice { get; set; }
        public decimal DepositAmount { get; set; }

        public BookingStatus Status { get; set; }

        public List<BookingDetailResponseDto> Services { get; set; } = new();
    }
}
