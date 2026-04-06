using BeautyBookingSystem.Application.DTOs.AdminCategory;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IAdminCategoryService
    {
        Task<List<GlobalCategoryDto>> GetAllAsync(bool onlyActive = false);
        Task<GlobalCategoryDto> GetByIdAsync(int id);
        Task<GlobalCategoryDto> CreateAsync(CreateCategoryRequest request);
        Task<bool> UpdateAsync(int id, UpdateCategoryRequest request);
        Task<bool> DeleteAsync(int id); 
    }
}
