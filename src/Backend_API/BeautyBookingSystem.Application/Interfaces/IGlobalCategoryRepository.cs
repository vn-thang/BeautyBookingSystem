using BeautyBookingSystem.Domain.Entities;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IGlobalCategoryRepository : IGenericRepository<GlobalCategory>
    {
        Task<List<GlobalCategory>> GetActiveAsync();
    }
}