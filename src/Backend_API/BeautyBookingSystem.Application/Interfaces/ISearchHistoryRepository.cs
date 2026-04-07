using BeautyBookingSystem.Domain.Entities;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface ISearchHistoryRepository
    {
        Task<List<SearchHistory>> GetByCustomerIdAsync(int customerId);
        Task<SearchHistory?> GetByCustomerAndKeywordAsync(int customerId, string keyword);
        Task AddAsync(SearchHistory entity);
        void Remove(SearchHistory entity);
        void RemoveRange(IEnumerable<SearchHistory> entities);
    }
}