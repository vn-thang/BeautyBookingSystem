using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.Store
{
    public class StoreWithServicesDto
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Address { get; set; }
        public decimal Rating { get; set; }

        public decimal? MinServicePrice { get; set; }

        public List<ServiceItemDto> Services { get; set; }
    }

    public class ServiceItemDto
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public decimal Price { get; set; }
        public int DurationMinutes { get; set; }
    }
}
