using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace BeautyBookingSystem.Infrastructure.Repositories
{
    public class GlobalCategoryRepository
        : GenericRepository<GlobalCategory>, IGlobalCategoryRepository
    {
        private readonly AppDbContext _context;

        public GlobalCategoryRepository(AppDbContext context) : base(context)
        {
            _context = context;
        }

        public async Task<List<GlobalCategory>> GetActiveAsync()
        {
            return await _context.GlobalCategories
                .Where(x => x.IsActive)
                .ToListAsync();
        }
    }
}