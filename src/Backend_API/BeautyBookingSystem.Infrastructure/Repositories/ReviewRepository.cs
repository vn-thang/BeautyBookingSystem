using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Application.Interfaces.Repositories;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace BeautyBookingSystem.Infrastructure.Repositories
{
    public class ReviewRepository : GenericRepository<Review>, IReviewRepository
    {
        private readonly AppDbContext _context;

        public ReviewRepository(AppDbContext context) : base(context)
        {
            _context = context;
        }

        public async Task<Review?> GetByBookingIdAsync(int bookingId)
        {
            return await _context.Reviews
                .Include(x => x.Store)
                .FirstOrDefaultAsync(x => x.BookingId == bookingId);
        }

        public async Task<List<Review>> GetByCustomerIdAsync(int customerId)
        {
            return await _context.Reviews
                .Include(x => x.Store)
                .Where(x => x.CustomerId == customerId)
                .OrderByDescending(x => x.CreatedAt)
                .ToListAsync();
        }
        public async Task<List<Review>> GetByStoreIdAsync(int storeId)
        {
            return await _context.Reviews
                .Include(r => r.Store)
                .Include(r => r.Customer)
                .Include(r => r.Booking)
                .Where(r => r.StoreId == storeId && !r.IsHidden)
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();
        }

        public async Task<List<Review>> GetPagedByStoreIdAsync(int storeId, int skip, int take)
        {
            return await _context.Reviews
                .Include(r => r.Store)
                .Include(r => r.Customer)
                .Include(r => r.Booking)
                .Where(r => r.StoreId == storeId && !r.IsHidden)
                .OrderByDescending(r => r.CreatedAt)
                .Skip(skip)
                .Take(take)
                .ToListAsync();
        }

        public async Task<int> CountByStoreIdAsync(int storeId)
        {
            return await _context.Reviews
                .CountAsync(r => r.StoreId == storeId && !r.IsHidden);
        }
    }
}