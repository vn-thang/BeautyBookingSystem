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

        public async Task<List<Review>> GetTopByStoreIdAsync(int storeId, int take = 5)
        {
            return await BuildStoreQuery(storeId)
                .OrderByDescending(r => r.Rating)
                .ThenByDescending(r => r.CreatedAt)
                .Take(take)
                .ToListAsync();
        }

        public async Task<List<Review>> GetPagedByStoreIdAsync(
            int storeId,
            int? rating,
            string sortBy,
            int skip,
            int take)
        {
            var query = BuildStoreQuery(storeId, rating);

            sortBy = (sortBy ?? "latest").Trim().ToLower();

            query = sortBy switch
            {
                "best" => query
                    .OrderByDescending(r => r.Rating)
                    .ThenByDescending(r => r.CreatedAt),

                _ => query
                    .OrderByDescending(r => r.CreatedAt)
            };

            return await query
                .Skip(skip)
                .Take(take)
                .ToListAsync();
        }

        public async Task<int> CountByStoreIdAsync(int storeId, int? rating = null)
        {
            var query = _context.Reviews
                .Where(r => r.StoreId == storeId && !r.IsHidden);

            if (rating.HasValue)
                query = query.Where(r => r.Rating == rating.Value);

            return await query.CountAsync();
        }

        private IQueryable<Review> BuildStoreQuery(int storeId, int? rating = null)
        {
            var query = _context.Reviews
                .AsNoTracking()
                .Include(r => r.Store)
                .Include(r => r.Customer)
                .Include(r => r.Booking)
                .Where(r => r.StoreId == storeId && !r.IsHidden);

            if (rating.HasValue)
                query = query.Where(r => r.Rating == rating.Value);

            return query;
        }
    }
}