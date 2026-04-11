using AutoMapper;
using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.DTOs.AdminCategory;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Services
{
    public class AdminCategoryService : IAdminCategoryService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public AdminCategoryService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<List<GlobalCategoryDto>> GetAllAsync(bool onlyActive = false)
        {
            var query = _unitOfWork.GlobalCategoryRepository.GetQueryable();

            if (onlyActive)
            {
                query = query.Where(c => c.IsActive);
            }

            var categories = await query.OrderBy(c => c.SortOrder).ToListAsync();

            return _mapper.Map<List<GlobalCategoryDto>>(categories);
        }

        public async Task<GlobalCategoryDto> GetByIdAsync(int id)
        {
            var category = await _unitOfWork.GlobalCategoryRepository.GetByIdAsync(id);
            if (category == null) throw new NotFoundException("Không tìm thấy danh mục!");

            return _mapper.Map<GlobalCategoryDto>(category);
        }

        public async Task<GlobalCategoryDto> CreateAsync(CreateCategoryRequest request)
        {
            var exists = await _unitOfWork.GlobalCategoryRepository.FirstOrDefaultAsync(c => c.Name.ToLower() == request.Name.ToLower());
            if (exists != null) throw new BadRequestException("Tên danh mục đã tồn tại!");

            var newCategory = _mapper.Map<GlobalCategory>(request);
            newCategory.IsActive = true;

            await _unitOfWork.GlobalCategoryRepository.AddAsync(newCategory);
            await _unitOfWork.SaveChangesAsync();

            return _mapper.Map<GlobalCategoryDto>(newCategory);
        }

       public async Task<bool> UpdateAsync(int id, UpdateCategoryRequest request)
{
    var category = await _unitOfWork.GlobalCategoryRepository.GetByIdAsync(id);
    if (category == null) throw new NotFoundException("Không tìm thấy danh mục!");
    if (category.IsActive == true && request.IsActive == false)
    {
        var hasRelatedServices = await _unitOfWork.ServiceRepository.GetQueryable()
            .AnyAsync(s => s.CategoryId == id && s.IsActive);

        if (hasRelatedServices)
        {
            throw new BadRequestException("Không thể lưu trạng thái Ẩn! Danh mục này vẫn còn các dịch vụ đang hoạt động bên trong.");
        }
    }

    _mapper.Map(request, category);

    _unitOfWork.GlobalCategoryRepository.Update(category);
    await _unitOfWork.SaveChangesAsync();

    return true;
}

public async Task<bool> DeleteAsync(int id)
{
    var category = await _unitOfWork.GlobalCategoryRepository.GetByIdAsync(id);
    if (category == null) throw new NotFoundException("Không tìm thấy danh mục!");
    
    var hasRelatedServices = await _unitOfWork.ServiceRepository.GetQueryable()
        .AnyAsync(s => s.CategoryId == id && s.IsActive);

    if (hasRelatedServices)
    {
        throw new BadRequestException("Không thể ẩn danh mục này vì vẫn còn các dịch vụ đang hoạt động bên trong. Vui lòng xóa hoặc chuyển các dịch vụ đó trước.");
    }
    
    category.IsActive = false;

    _unitOfWork.GlobalCategoryRepository.Update(category);
    await _unitOfWork.SaveChangesAsync();

    return true;
}
    }
}
