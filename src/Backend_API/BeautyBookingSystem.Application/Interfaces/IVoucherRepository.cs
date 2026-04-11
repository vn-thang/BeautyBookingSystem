using BeautyBookingSystem.Domain.Entities;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IVoucherRepository : IGenericRepository<Voucher>
    {
        Task<List<Voucher>> GetByStoreAsync(int storeId, int? serviceId = null);
        Task<List<Voucher>> GetActiveByStoreAsync(int storeId, int? serviceId = null);
        Task<Voucher?> GetByCodeAsync(string code);
        Task<List<Voucher>> GetAllActiveAsync();
        Task<List<Voucher>> GetActiveByServiceAsync(int serviceId, int? storeId = null);
        Task<List<Voucher>> GetActiveServiceVouchersAsync(int? storeId = null);
    }
}