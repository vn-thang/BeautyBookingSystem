using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace BeautyBookingSystem.Infrastructure.Repositories
{
    public class SearchHistoryRepository : ISearchHistoryRepository
    {
        private readonly AppDbContext _context;

        public SearchHistoryRepository(AppDbContext context)
        {
            _context = context;
        }

        public async Task<List<SearchHistory>> GetByCustomerIdAsync(int customerId)
        {
            return await _context.SearchHistories
                .Where(x => x.CustomerId == customerId)
                .OrderByDescending(x => x.Id)
                .ToListAsync();
        }

        public async Task<SearchHistory?> GetByCustomerAndKeywordAsync(int customerId, string keyword)
        {
            return await _context.SearchHistories
                .FirstOrDefaultAsync(x => x.CustomerId == customerId && x.Keyword == keyword);
        }

        public async Task AddAsync(SearchHistory entity)
        {
            await _context.SearchHistories.AddAsync(entity);
        }

        public void Remove(SearchHistory entity)
        {
            _context.SearchHistories.Remove(entity);
        }

        public void RemoveRange(IEnumerable<SearchHistory> entities)
        {
            _context.SearchHistories.RemoveRange(entities);
        }
    }
}