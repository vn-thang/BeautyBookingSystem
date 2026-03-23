using BeautyBookingSystem.Application.DTOs.Service;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using Microsoft.EntityFrameworkCore;


public class ServiceService : IServiceService
{
    private readonly IUnitOfWork _unitOfWork;

    public ServiceService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    public async Task<List<Service>> GetByStoreAsync(int storeId)
        => await _unitOfWork.ServiceRepository.GetByStoreAsync(storeId);

    public async Task<List<Service>> GetByCategoryAsync(int categoryId)
        => await _unitOfWork.ServiceRepository.GetByCategoryAsync(categoryId);

    public async Task<List<Service>> GetByGroupAsync(int groupId)
        => await _unitOfWork.ServiceRepository.GetByGroupAsync(groupId);

    public async Task<List<Service>> GetFeaturedAsync()
        => await _unitOfWork.ServiceRepository.GetFeaturedAsync();

    public async Task<List<Service>> GetAllAsync()
        => await _unitOfWork.ServiceRepository.GetAllActiveAsync();
    public async Task<ServiceDetailDto?> GetByIdAsync(int id)
    {
        var service = await _unitOfWork.ServiceRepository
            .GetQueryable()
            .Include(x => x.Store)
            .Include(x => x.Category)
            .Include(x => x.Group)
            .FirstOrDefaultAsync(x => x.Id == id && x.IsActive);

        if (service == null) return null;

        return new ServiceDetailDto
        {
            Id = service.Id,
            Name = service.Name,
            Description = service.Description,
            ImageUrl = service.ImageUrl,
            Price = service.Price,
            DurationMinutes = service.DurationMinutes,
            IsFeatured = service.IsFeatured,
            IsActive = service.IsActive,
            StoreId = service.StoreId,
            StoreName = service.Store.Name,

            CategoryId = service.CategoryId,
            CategoryName = service.Category.Name,
            GroupId = service.GroupId,
            GroupName = service.Group != null ? service.Group.Name : null
        };
    }
}