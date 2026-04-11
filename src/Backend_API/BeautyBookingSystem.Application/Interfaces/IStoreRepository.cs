using BeautyBookingSystem.Domain.Entities;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IStoreRepository : IGenericRepository<Store>
    {
        Task<List<Store>> GetAllActiveAsync();
        Task<List<Store>> GetApprovedAsync();
        Task<Store?> GetDetailAsync(int id);
    }
}