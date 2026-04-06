using BeautyBookingSystem.Application.DTOs.Common;
using BeautyBookingSystem.Domain.Enums;
using System;

namespace BeautyBookingSystem.Application.DTOs.AdminBooking
{
    public class AdminBookingFilterRequest : PagingRequest
    {
        public string? SearchTerm { get; set; }
        public int? StoreId { get; set; }
        public BookingStatus? Status { get; set; }
        public PaymentStatus? PaymentStatus { get; set; }
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
    }
}