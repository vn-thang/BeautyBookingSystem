using BeautyBookingSystem.Application.DTOs.GlobalCategory;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
        public interface IGlobalCategoryService
        {
            Task<List<GlobalCategoryDto>> GetAllAsync();
            Task<List<GlobalCategoryDto>> GetActiveAsync();
            Task<GlobalCategoryDto?> GetByIdAsync(int id);

        }
    
}
