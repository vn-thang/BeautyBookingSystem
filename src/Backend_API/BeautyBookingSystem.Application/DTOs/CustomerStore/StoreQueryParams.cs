using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.CustomerStore
{
    public class StoreQueryParams
    {
        public int CategoryId { get; set; }
        public int? GroupId { get; set; }

        public string? Q { get; set; }

        public double? Lat { get; set; }
        public double? Lng { get; set; }

        public string? Sort { get; set; }

        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 10;
    }
}
