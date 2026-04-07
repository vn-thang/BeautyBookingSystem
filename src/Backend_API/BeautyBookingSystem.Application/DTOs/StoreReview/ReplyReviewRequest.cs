using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.StoreReview
{
    public class ReplyReviewRequest
    {
        [Required(ErrorMessage = "Nội dung trả lời không được để trống")]
        [MaxLength(500, ErrorMessage = "Nội dung trả lời tối đa 500 ký tự")]
        public string? Reply { get; set; }
    }
}
