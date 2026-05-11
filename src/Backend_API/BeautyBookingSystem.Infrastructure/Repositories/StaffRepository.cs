using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Application.Interfaces.Repositories;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace BeautyBookingSystem.Infrastructure.Repositories
{
    public class StaffRepository
        : GenericRepository<Staff>, IStaffRepository
    {


        public StaffRepository(AppDbContext context) : base(context)
        {
        }

        public async Task<List<Staff>> GetByStoreIdAsync(int storeId)
        {
            return await _context.Staffs
                .Where(s => s.StoreId == storeId)
                .ToListAsync();
        }
        public async Task<List<Staff>> GetStaffsWithSchedulesAndLeavesAsync(int storeId)
        {
            return await _context.Staffs
                .Include(s => s.Schedules)
                .Include(s => s.Leaves)
                .Where(s => s.StoreId == storeId && s.IsActive)
                .ToListAsync();
        }
    }
}