using BeautyBookingSystem.Domain.Entities;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IServiceGroupRepository : IGenericRepository<ServiceGroup>
    {
        Task<List<ServiceGroup>> GetAllOrderedAsync();
        Task<List<ServiceGroup>> GetByStoreAsync(int storeId);

    }
}