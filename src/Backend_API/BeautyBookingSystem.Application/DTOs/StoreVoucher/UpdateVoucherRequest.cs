using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.StoreVoucher
{
    public class UpdateVoucherRequest
    {
        public DateTime EndDate { get; set; }
        public int? ServiceId { get; set; }
        public string? ImageUrl { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Giới hạn sử dụng phải ít nhất là 1")]
        public int UsageLimit { get; set; }
    }
}
