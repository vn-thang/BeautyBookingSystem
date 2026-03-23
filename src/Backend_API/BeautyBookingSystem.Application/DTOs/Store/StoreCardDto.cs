using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.Store
{
    public class StoreCardDto
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Address { get; set; }
        public string? CoverImageUrl { get; set; }
        public decimal AverageRating { get; set; }
    }
}
