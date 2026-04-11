using BeautyBookingSystem.Application.DTOs.Voucher;
namespace BeautyBookingSystem.Application.Interfaces
{
public interface IVoucherService
{
    Task<List<VoucherDto>> GetByStoreAsync(int storeId, int? serviceId = null);
    Task<List<VoucherDto>> GetActiveByStoreAsync(int storeId, int? serviceId = null);
    Task<List<VoucherDto>> GetAllActiveAsync();
    Task<VoucherDto?> GetByCodeAsync(string code);
    Task<List<VoucherDto>> GetActiveByServiceAsync(int serviceId, int? storeId = null);
    Task<List<ServiceVoucherHomeDto>> GetActiveServiceVouchersAsync(int? storeId = null);
    }
}