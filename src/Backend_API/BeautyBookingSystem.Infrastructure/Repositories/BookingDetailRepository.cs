using BeautyBookingSystem.Application.Interfaces.Repositories;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Domain.Enums;
using BeautyBookingSystem.Infrastructure.Data;
using BeautyBookingSystem.Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore;

public class BookingDetailRepository
    : GenericRepository<BookingDetail>, IBookingDetailRepository
{
    public BookingDetailRepository(AppDbContext context) : base(context)
    {
    }
    public async Task<List<BookingDetail>> GetByStoreAndDateAsync(int storeId, DateTime date)
    {
        return await _context.BookingDetails
            .Include(x => x.Booking)
            .Where(x =>
                x.Booking.StoreId == storeId &&
                x.AppointmentDate.Date == date.Date)
            .ToListAsync();
    }
    public async Task<bool> IsStaffBusy(
    int? staffId,
    DateTime date,
    TimeSpan start,
    TimeSpan end)
    {
        if (staffId == null)
            return false;

        return await _context.BookingDetails
            .AnyAsync(d =>
                d.StaffId == staffId &&
                d.AppointmentDate.Date == date.Date &&
                d.Status != BookingDetailStatus.Cancelled &&
                d.StartTime < end &&
                d.EndTime > start
            );
    }
}