using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.DTOs.Category
{
    public class CreateCategoryRequest
    {
        public string Name { get; set; } = null!;
        public string? IconUrl { get; set; }
        public int SortOrder { get; set; } = 0;
    }
}
