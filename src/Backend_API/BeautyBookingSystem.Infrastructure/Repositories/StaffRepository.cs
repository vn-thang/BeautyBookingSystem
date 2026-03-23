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
        private readonly AppDbContext _context;

        public StaffRepository(AppDbContext context) : base(context)
        {
            _context = context;
        }

        public async Task<List<Staff>> GetByStoreIdAsync(int storeId)
        {
            return await _context.Staffs
                .Where(s => s.StoreId == storeId)
                .ToListAsync();
        }
    }
}