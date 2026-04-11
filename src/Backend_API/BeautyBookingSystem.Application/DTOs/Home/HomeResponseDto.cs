using BeautyBookingSystem.Application.DTOs.GlobalCategory;
using BeautyBookingSystem.Application.DTOs.ServiceGroup;
using BeautyBookingSystem.Application.DTOs.SystemContent;
using BeautyBookingSystem.Application.DTOs.Voucher;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BeautyBookingSystem.Application.DTOs.CustomerStore;

namespace BeautyBookingSystem.Application.DTOs.Home
{
    public class HomeResponseDto
    {
        public string? UserName { get; set; }
        public string? LocationName { get; set; }

        public List<GlobalCategoryDto> Categories { get; set; } = new();
        public List<ServiceGroupDto> ServiceGroups { get; set; } = new();
        public List<StoreNearbyDto> NearbyStores { get; set; } = new();
        public List<StoreNearbyDto>? TopRatedStores { get; set; }
        public List<ServiceVoucherHomeDto>? Vouchers { get; set; } 
        public List<SystemContentDto>? SystemContents { get; set; }
    }
}
