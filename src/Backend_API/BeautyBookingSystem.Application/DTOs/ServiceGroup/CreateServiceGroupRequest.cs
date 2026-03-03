using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.ServiceGroup
{
    public class CreateServiceGroupRequest
    {
        [Required(ErrorMessage = "Vui lòng nhập tên nhóm dịch vụ")]
        public string Name { get; set; } = string.Empty;
        public int SortOrder { get; set; } = 0;
    }
}
