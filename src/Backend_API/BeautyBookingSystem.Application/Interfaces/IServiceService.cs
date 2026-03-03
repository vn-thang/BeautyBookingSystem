using BeautyBookingSystem.Application.DTOs.Service;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IServiceService
    {
        Task<List<ServiceDto>> GetAllByCurrentStoreAsync(bool onlyActive = true);
        Task<ServiceDto> GetByIdAsync(int id);
        Task<ServiceDto> CreateAsync(CreateServiceRequest request);
        Task<bool> UpdateAsync(int id, UpdateServiceRequest request);
        Task<bool> DeleteAsync(int id); 
    }
}
