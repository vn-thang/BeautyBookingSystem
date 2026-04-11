using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace BeautyBookingSystem.Application.DTOs.StoreBooking
{
    public class CreateStoreBookingRequest
    {
        [Required(ErrorMessage = "Tên khách hàng là bắt buộc")]
        public string CustomerName { get; set; } = string.Empty;
        
        public string? CustomerPhone { get; set; }

        [Required]
        public DateTime AppointmentDate { get; set; }

        public string? Note { get; set; }

        [Required, MinLength(1, ErrorMessage = "Phải chọn ít nhất 1 dịch vụ")]
        public List<StoreBookingServiceRequest> Services { get; set; } = new();
    }

    public class StoreBookingServiceRequest
    {
        public int ServiceId { get; set; }
        public TimeSpan StartTime { get; set; }
        public int? StaffId { get; set; } 
    }
}