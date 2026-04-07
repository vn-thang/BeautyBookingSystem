using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Infrastructure.Data;
using BeautyBookingSystem.Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore;

namespace BeautyBookingSystem.Infrastructure.Repositories
{
    public class VoucherRepository : GenericRepository<Voucher>, IVoucherRepository
    {
        private readonly AppDbContext _context;

        public VoucherRepository(AppDbContext context) : base(context)
        {
            _context = context;
        }

        public async Task<List<Voucher>> GetByStoreAsync(int storeId, int? serviceId = null)
        {
            var query = _context.Vouchers
                .AsNoTracking()
                .Where(v => v.StoreId == storeId);

            // Nếu có serviceId thì chỉ lấy:
            // - voucher dùng cho toàn store (ServiceId == null)
            // - voucher đúng service đó
            if (serviceId.HasValue)
            {
                query = query.Where(v => v.ServiceId == null || v.ServiceId == serviceId.Value);
            }

            return await query
                .OrderByDescending(v => v.Id)
                .ToListAsync();
        }

        public async Task<List<Voucher>> GetActiveByStoreAsync(int storeId, int? serviceId = null)
        {
            var now = DateTime.UtcNow;

            var query = _context.Vouchers
                .AsNoTracking()
                .Where(v =>
                    v.StoreId == storeId &&
                    v.StartDate <= now &&
                    v.EndDate >= now &&
                    v.UsedCount < v.UsageLimit);

            // Nếu có serviceId thì chỉ lấy:
            // - voucher dùng cho toàn store (ServiceId == null)
            // - voucher đúng service đó
            if (serviceId.HasValue)
            {
                query = query.Where(v => v.ServiceId == null || v.ServiceId == serviceId.Value);
            }

            return await query
                .OrderByDescending(v => v.Id)
                .ToListAsync();
        }

        public async Task<List<Voucher>> GetAllActiveAsync()
        {
            var now = DateTime.UtcNow;

            return await _context.Vouchers
                .AsNoTracking()
                .Where(v =>
                    v.StartDate <= now &&
                    v.EndDate >= now &&
                    v.UsedCount < v.UsageLimit)
                .OrderByDescending(v => v.Id)
                .ToListAsync();
        }

        public async Task<Voucher?> GetByCodeAsync(string code)
        {
            return await _context.Vouchers
                .AsNoTracking()
                .FirstOrDefaultAsync(v => v.Code == code);
        }
        public async Task<List<Voucher>> GetActiveByServiceAsync(int serviceId, int? storeId = null)
        {
            var now = DateTime.UtcNow;

            var query = _context.Vouchers
                .AsNoTracking()
                .Where(v =>
                    v.ServiceId == serviceId &&
                    v.StartDate <= now &&
                    v.EndDate >= now &&
                    v.UsedCount < v.UsageLimit);

            if (storeId.HasValue)
            {
                query = query.Where(v => v.StoreId == storeId.Value);
            }

            return await query.OrderByDescending(v => v.Id).ToListAsync();
        }
        public async Task<List<Voucher>> GetActiveServiceVouchersAsync(int? storeId = null)
        {
            var now = DateTime.Now;

            var query = _context.Vouchers
                .AsNoTracking()
                .Include(v => v.Service)
                .Where(v =>
                    v.ServiceId != null &&
                    v.StartDate <= now &&
                    v.EndDate >= now &&
                    v.UsedCount < v.UsageLimit);

            if (storeId.HasValue)
            {
                query = query.Where(v => v.StoreId == storeId.Value);
            }

            return await query.OrderByDescending(v => v.Id).ToListAsync();
        }
    }
}