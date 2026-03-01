using BeautyBookingSystem.Domain.Entities;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace BeautyBookingSystem.Application.DTOs.Auth
{        
    public class RegisterPartnerRequest
        {

            [Required(ErrorMessage = "Tên chủ tiệm không được để trống.")]
            [StringLength(100, ErrorMessage = "Tên chủ tiệm không được vượt quá 100 ký tự.")]
            public string OwnerName { get; set; } = string.Empty;

            [Required(ErrorMessage = "Số điện thoại không được để trống.")]
            [RegularExpression(@"^(0[3|5|7|8|9])+([0-9]{8})$", ErrorMessage = "Số điện thoại không đúng định dạng (VD: 0912345678).")]
            public string Phone { get; set; } = string.Empty;

            [Required(ErrorMessage = "Email không được để trống.")]
            [EmailAddress(ErrorMessage = "Email không đúng định dạng.")]
            public string Email { get; set; } = string.Empty;

            [Required(ErrorMessage = "Mật khẩu không được để trống.")]
            [StringLength(50, MinimumLength = 6, ErrorMessage = "Mật khẩu phải từ 6 đến 50 ký tự.")]
       
            public string Password { get; set; } = string.Empty;

            [Required(ErrorMessage = "Tên cửa hàng không được để trống.")]
            [StringLength(200, ErrorMessage = "Tên cửa hàng không được vượt quá 200 ký tự.")]
            public string StoreName { get; set; } = string.Empty;

            [Required(ErrorMessage = "Địa chỉ cửa hàng không được để trống.")]
            [StringLength(500, ErrorMessage = "Địa chỉ không được vượt quá 500 ký tự.")]
            public string StoreAddress { get; set; } = string.Empty;

            [StringLength(1000, ErrorMessage = "Mô tả cửa hàng không được vượt quá 1000 ký tự.")]
            public string? StoreDescription { get; set; }
        }
    }
