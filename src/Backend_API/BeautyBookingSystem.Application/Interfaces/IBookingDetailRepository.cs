using BeautyBookingSystem.Domain.Entities;

namespace BeautyBookingSystem.Application.Interfaces.Repositories
{
    public interface IBookingDetailRepository : IGenericRepository<BookingDetail>
    {
        Task<bool> IsStaffBusy(
            int? staffId,
            DateTime date,
            TimeSpan start,
            TimeSpan end
        );
        Task<List<BookingDetail>> GetByStoreAndDateAsync(int storeId, DateTime date);
    }
}