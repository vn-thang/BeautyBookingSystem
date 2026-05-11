using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace BeautyBookingSystem.Infrastructure.Repositories
{
    public class ServiceGroupRepository
        : GenericRepository<ServiceGroup>, IServiceGroupRepository
    {

        public ServiceGroupRepository(AppDbContext context) : base(context)
        {
        }

        public async Task<List<ServiceGroup>> GetAllOrderedAsync()
        {
            return await _context.Set<ServiceGroup>()
                .OrderBy(x => x.SortOrder)
                .ToListAsync();
        }

        public async Task<List<ServiceGroup>> GetByStoreAsync(int storeId)
        {
            return await _context.Set<ServiceGroup>()
                .Where(x => x.StoreId == storeId)
                .OrderBy(x => x.SortOrder)
                .ToListAsync();
        }

    }
}