using BeautyBookingSystem.Application.DTOs.StoreService;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.StoreServiceGroup
{
    public class ServiceGroupDto
    {
        public int Id { get; set; }
        public int StoreId { get; set; }
        public string Name { get; set; } = string.Empty;
        public int SortOrder { get; set; }
        public List<ServiceDto> Services { get; set; } = new List<ServiceDto>();
    }
}
