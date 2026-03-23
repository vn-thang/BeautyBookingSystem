using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Domain.Enums;
using BeautyBookingSystem.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace BeautyBookingSystem.Infrastructure.Repositories
{
    public class StoreRepository
        : GenericRepository<Store>, IStoreRepository
    {
        private readonly AppDbContext _context;

        public StoreRepository(AppDbContext context) : base(context)
        {
            _context = context;
        }
        public async Task<Store?> GetStoreProfileAsync(int storeId)
        {
            return await _context.Stores
                .Include(s => s.OperatingHours)
                .FirstOrDefaultAsync(s => s.Id == storeId);
        }

        public async Task<List<Store>> GetApprovedAsync()
        {
            return await _context.Stores
                .Where(x => x.ApprovalStatus == ApprovalStatus.Approved)
                .ToListAsync();
        }

        public async Task<Store?> GetDetailAsync(int id)
        {
            return await _context.Stores
                .Include(x => x.ServiceGroups)
                .Include(x => x.Services)
                .Include(x => x.Reviews)
                .Include(x => x.Banners)
                .Include(x => x.OperatingHours)
                .FirstOrDefaultAsync(x => x.Id == id);
        }

        public Task<List<Store>> GetAllActiveAsync()
        {
            throw new NotImplementedException();
        }
    }
}