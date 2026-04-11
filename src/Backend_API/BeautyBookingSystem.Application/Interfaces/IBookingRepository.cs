using BeautyBookingSystem.Domain.Entities;

namespace BeautyBookingSystem.Application.Interfaces.Repositories
{
    public interface IBookingRepository : IGenericRepository<Booking>
    {
        Task<List<Booking>> GetByCustomerAsync(int customerId);
        Task<Booking?> GetByIdWithDetailsAsync(int bookingId);
    }
}