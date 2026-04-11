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
        Task<List<ServiceGroupDto>> GetAllAsync();
        Task<List<ServiceGroupDto>> GetByStoreAsync(int storeId);
        Task<ServiceGroupDto?> GetByIdAsync(int id);
    }
}
