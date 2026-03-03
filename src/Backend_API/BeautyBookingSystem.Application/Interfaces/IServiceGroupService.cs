using BeautyBookingSystem.Application.DTOs.ServiceGroup;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IServiceGroupService
    {
        Task<List<ServiceGroupDto>> GetAllByCurrentStoreAsync();
        Task<ServiceGroupDto> GetByIdAsync(int id);
        Task<ServiceGroupDto> CreateAsync(CreateServiceGroupRequest request);
        Task<bool> UpdateAsync(int id, UpdateServiceGroupRequest request);
        Task<bool> DeleteAsync(int id);
    }
}
