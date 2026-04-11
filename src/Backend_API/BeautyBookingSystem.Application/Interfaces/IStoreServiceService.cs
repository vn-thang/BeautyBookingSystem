using BeautyBookingSystem.Application.DTOs.StoreService;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IStoreServiceService
    {
        Task<List<ServiceDto>> GetAllByCurrentStoreAsync(bool onlyActive = true);
        Task<ServiceDto> GetByIdAsync(int id);
        Task<List<SimpleServiceDto>> GetServicesForDropdownAsync();
        Task<ServiceDto> CreateAsync(CreateServiceRequest request);
        Task<bool> UpdateAsync(int id, UpdateServiceRequest request);
        Task<bool> DeleteAsync(int id); 
    }
}
