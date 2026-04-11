using BeautyBookingSystem.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IReviewRepository : IGenericRepository<Review>
    {
        Task<Review?> GetByBookingIdAsync(int bookingId);
        Task<List<Review>> GetByCustomerIdAsync(int customerId);
        Task<List<Review>> GetByStoreIdAsync(int storeId);
        Task<List<Review>> GetPagedByStoreIdAsync(int storeId, int skip, int take);
        Task<int> CountByStoreIdAsync(int storeId);
    }
}
