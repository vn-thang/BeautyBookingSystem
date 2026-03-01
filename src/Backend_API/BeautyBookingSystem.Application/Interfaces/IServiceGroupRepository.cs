using BeautyBookingSystem.Domain.Entities;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IServiceGroupRepository : IGenericRepository<ServiceGroup>
    {
        Task<List<ServiceGroup>> GetAllAsync();
        Task<List<ServiceGroup>> GetByStoreIdAsync(int storeId);
 
    }
}