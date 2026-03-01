using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace BeautyBookingSystem.Infrastructure.Repositories
{
    public class ServiceGroupRepository
        : GenericRepository<ServiceGroup>, IServiceGroupRepository
    {
        private readonly AppDbContext _context;

        public ServiceGroupRepository(AppDbContext context) : base(context)
        {
            _context = context;
        }

        public async Task<List<ServiceGroup>> GetAllAsync()
        {
            return await _context.ServiceGroups.ToListAsync();
        }

        public async Task<List<ServiceGroup>> GetByStoreIdAsync(int storeId)
        {
            return await _context.ServiceGroups
                .Where(x => x.StoreId == storeId)
                .ToListAsync();
        }
        
    }
}