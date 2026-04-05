using BeautyBookingSystem.Application.DTOs.Service;
using BeautyBookingSystem.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IServiceService
    {
        Task<List<Service>> GetByStoreAsync(int storeId);
        Task<List<Service>> GetByCategoryAsync(int categoryId);
        Task<List<Service>> GetByGroupAsync(int groupId);
        Task<List<Service>> GetFeaturedAsync();
        Task<List<Service>> GetAllAsync();
        Task<ServiceDetailDto?> GetByIdAsync(int id, int? customerId = null);
    }
}
