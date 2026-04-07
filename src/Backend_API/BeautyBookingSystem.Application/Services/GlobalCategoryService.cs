// Application/Services/GlobalCategoryService.cs
using BeautyBookingSystem.Application.DTOs.GlobalCategory;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace BeautyBookingSystem.Application.Services
{
    public class GlobalCategoryService : IGlobalCategoryService
    {
        private readonly IUnitOfWork _unitOfWork;

        public GlobalCategoryService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<List<GlobalCategoryDto>> GetAllAsync()
        {
            var list = await _unitOfWork.GlobalCategoryRepository.GetAllAsync();

            return list.Select(x => new GlobalCategoryDto
            {
                Id = x.Id,
                Name = x.Name,
                IconUrl = x.IconUrl,
                IsActive = x.IsActive,
                SortOrder = x.SortOrder
            }).ToList();
        }

        public async Task<List<GlobalCategoryDto>> GetActiveAsync()
        {
            var list = await _unitOfWork.GlobalCategoryRepository.GetActiveAsync();

            return list.Select(x => new GlobalCategoryDto
            {
                Id = x.Id,
                Name = x.Name,
                IconUrl = x.IconUrl,
                IsActive = x.IsActive,
                SortOrder = x.SortOrder
            }).ToList();
        }

        public async Task<GlobalCategoryDto?> GetByIdAsync(int id)
        {
            var entity = await _unitOfWork.GlobalCategoryRepository.GetByIdAsync(id);

            if (entity == null) return null;

            return new GlobalCategoryDto
            {
                Id = entity.Id,
                Name = entity.Name,
                IconUrl = entity.IconUrl,
                IsActive = entity.IsActive,
                SortOrder = entity.SortOrder
            };
        }
    }
}