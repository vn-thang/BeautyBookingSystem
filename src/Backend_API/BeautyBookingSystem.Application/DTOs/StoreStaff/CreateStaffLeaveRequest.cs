using System.ComponentModel.DataAnnotations;

namespace BeautyBookingSystem.Application.DTOs.StoreStaff
{
public class CreateStaffLeaveRequest
    {
        [Required(ErrorMessage = "Vui lòng chọn thời gian bắt đầu nghỉ")]
        public DateTime FromDate { get; set; }

        [Required(ErrorMessage = "Vui lòng chọn thời gian kết thúc nghỉ")]
        public DateTime ToDate { get; set; }

        public string? Reason { get; set; }
    }
}