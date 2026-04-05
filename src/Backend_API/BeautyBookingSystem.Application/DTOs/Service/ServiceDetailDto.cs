using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.Service
{
    public class ServiceDetailDto
    {
        public int Id { get; set; }

        public int StoreId { get; set; }
        public string StoreName { get; set; } = string.Empty;

        public int CategoryId { get; set; }
        public string CategoryName { get; set; } = string.Empty;

        public int? GroupId { get; set; }
        public string? GroupName { get; set; }

        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? ImageUrl { get; set; }

        public decimal Price { get; set; }
        public int DurationMinutes { get; set; }

        public bool IsActive { get; set; }
        public bool IsFeatured { get; set; }
        public bool IsFavorite { get; set; }
    }
}
