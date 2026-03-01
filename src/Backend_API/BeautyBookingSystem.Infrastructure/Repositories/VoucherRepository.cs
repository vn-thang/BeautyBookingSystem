using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Infrastructure.Data;
using BeautyBookingSystem.Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore;

public class VoucherRepository
    : GenericRepository<Voucher>, IVoucherRepository
{
    private readonly AppDbContext _context;

    public VoucherRepository(AppDbContext context)
        : base(context)
    {
        _context = context;
    }

    public async Task<List<Voucher>> GetActiveAsync()
    {
        var now = DateTime.UtcNow;

        return await _context.Vouchers
            .Where(x =>
                x.StartDate <= now &&
                x.EndDate >= now &&
                x.UsedCount < x.UsageLimit
            )
            .ToListAsync();
    }
}