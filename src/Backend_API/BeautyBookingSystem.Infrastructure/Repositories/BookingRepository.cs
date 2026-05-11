using BeautyBookingSystem.Application.Interfaces.Repositories;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Domain.Enums;
using BeautyBookingSystem.Infrastructure.Data;
using BeautyBookingSystem.Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore;

public class BookingRepository
    : GenericRepository<Booking>, IBookingRepository
{

    public BookingRepository(AppDbContext context) : base(context)
    {
    }

    public async Task<List<Booking>> GetByCustomerAsync(int customerId)
    {
        return await _context.Bookings
            .Where(b => b.CustomerId == customerId)
            .Include(b => b.Store)
            .Include(b => b.BookingDetails)
                .ThenInclude(d => d.Service)
            .Include(b => b.BookingDetails)
                .ThenInclude(d => d.Staff)
            .Include(b => b.Payments)
            .OrderByDescending(b => b.CreatedAt)
            .ToListAsync();
    }

    public async Task<Booking?> GetByIdWithDetailsAsync(int bookingId)
    {
        return await _context.Bookings
            .Where(b => b.Id == bookingId)
            .Include(b => b.Store)
            .Include(b => b.BookingDetails)
                .ThenInclude(d => d.Service)
            .Include(b => b.BookingDetails)
                .ThenInclude(d => d.Staff)
            .Include(b => b.Payments)
            .FirstOrDefaultAsync();
    }
}