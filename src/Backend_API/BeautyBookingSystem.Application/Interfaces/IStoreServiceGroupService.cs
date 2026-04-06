using BeautyBookingSystem.Application.DTOs.StoreServiceGroup;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IStoreServiceGroupService
    {
        Task<List<ServiceGroupDto>> GetAllByCurrentStoreAsync();
        Task<ServiceGroupDto> GetByIdAsync(int id);
        Task<ServiceGroupDto> CreateAsync(CreateServiceGroupRequest request);
        Task<bool> UpdateAsync(int id, UpdateServiceGroupRequest request);
        Task<bool> DeleteAsync(int id);
    }
}
