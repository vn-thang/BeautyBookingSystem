using BeautyBookingSystem.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.Booking
{
    public class BookingListItemDto
    {
        public int Id { get; set; }
        public DateTime CreatedAt { get; set; }
        public decimal FinalPrice { get; set; }
        public decimal DepositAmount { get; set; }
        public string StoreName { get; set; } = string.Empty;
        public BookingStatus Status { get; set; }
    }
}
