using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.Staff
{
    public class CreateStaffRequest
    {
        [Required(ErrorMessage = "Vui lòng nhập tên nhân viên")]
        public string FullName { get; set; } = null!;

        public string? AvatarUrl { get; set; }

        [Required(ErrorMessage = "Vui lòng nhập vị trí (Thợ chính/Thợ phụ...)")]
        public string Position { get; set; } = null!;
    }
}
