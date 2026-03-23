// Application/Services/ServiceGroupService.cs
using BeautyBookingSystem.Application.DTOs.ServiceGroup;
using BeautyBookingSystem.Application.Interfaces;
using System.Linq;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace BeautyBookingSystem.Application.Services
{
    public class ServiceGroupService : IServiceGroupService
    {
        private readonly IUnitOfWork _unitOfWork;

        public ServiceGroupService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }
        public async Task<List<ServiceGroupDto>> GetAllAsync()
        {
            var list = await _unitOfWork.ServiceGroupRepository.GetAllOrderedAsync();

            return list.Select(x => new ServiceGroupDto
            {
                Id = x.Id,
                StoreId = x.StoreId,
                Name = x.Name,
                SortOrder = x.SortOrder
            }).ToList();
        }
        public async Task<List<ServiceGroupDto>> GetByStoreAsync(int storeId)
        {
            var list = await _unitOfWork.ServiceGroupRepository.GetByStoreAsync(storeId);

            return list.Select(x => new ServiceGroupDto
            {
                Id = x.Id,
                StoreId = x.StoreId,
                Name = x.Name,
                SortOrder = x.SortOrder
            }).ToList();
        }

        public async Task<ServiceGroupDto?> GetByIdAsync(int id)
        {
            var entity = await _unitOfWork.ServiceGroupRepository.GetByIdAsync(id);

            if (entity == null) return null;

            return new ServiceGroupDto
            {
                Id = entity.Id,
                StoreId = entity.StoreId,
                Name = entity.Name,
                SortOrder = entity.SortOrder
            };
        }
    }
}