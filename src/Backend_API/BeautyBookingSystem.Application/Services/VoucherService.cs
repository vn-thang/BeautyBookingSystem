using BeautyBookingSystem.Application.DTOs.Voucher;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;

public interface IVoucherService
{
    Task<List<VoucherDto>> GetByStoreAsync(int storeId, int? serviceId = null);
    Task<List<VoucherDto>> GetActiveByStoreAsync(int storeId, int? serviceId = null);
    Task<List<VoucherDto>> GetAllActiveAsync();
    Task<VoucherDto?> GetByCodeAsync(string code);
    Task<List<VoucherDto>> GetActiveByServiceAsync(int serviceId, int? storeId = null);
    Task<List<ServiceVoucherHomeDto>> GetActiveServiceVouchersAsync(int? storeId = null);
}

public class VoucherService : IVoucherService
{
    private readonly IUnitOfWork _unitOfWork;

    public VoucherService(IUnitOfWork unitOfWork)
    {
        _unitOfWork = unitOfWork;
    }

    private static VoucherDto MapToDto(Voucher v)
    {
        return new VoucherDto
        {
            Id = v.Id,
            StoreId = v.StoreId,
            ServiceId = v.ServiceId,
            Code = v.Code,
            ImageUrl = v.ImageUrl,
            DiscountType = v.DiscountType,
            DiscountValue = v.DiscountValue,
            MinOrderValue = v.MinOrderValue,
            MaxDiscount = v.MaxDiscount,
            StartDate = v.StartDate,
            EndDate = v.EndDate
        };
    }

    private static ServiceVoucherHomeDto MapToHomeDto(Voucher v)
    {
        var originalPrice = v.Service?.Price ?? 0m;

        decimal discountAmount = v.DiscountType == 0
            ? originalPrice * v.DiscountValue / 100m
            : v.DiscountValue;

        if (v.MaxDiscount > 0 && discountAmount > v.MaxDiscount)
            discountAmount = v.MaxDiscount;

        if (discountAmount > originalPrice)
            discountAmount = originalPrice;

        var discountedPrice = originalPrice - discountAmount;

        return new ServiceVoucherHomeDto
        {
            Id = v.Id,
            StoreId = v.StoreId,
            ServiceId = v.ServiceId ?? 0,
            Code = v.Code,
            ImageUrl = v.ImageUrl,
            ServiceName = v.Service?.Name ?? string.Empty,
            OriginalPrice = originalPrice,
            DiscountAmount = discountAmount,
            DiscountedPrice = discountedPrice,
            DiscountType = v.DiscountType,
            DiscountValue = v.DiscountValue,
            MinOrderValue = v.MinOrderValue,
            MaxDiscount = v.MaxDiscount,
            StartDate = v.StartDate,
            EndDate = v.EndDate
        };
    }

    public async Task<List<VoucherDto>> GetByStoreAsync(int storeId, int? serviceId = null)
    {
        var vouchers = await _unitOfWork.VoucherRepository.GetByStoreAsync(storeId, serviceId);
        return vouchers.Select(MapToDto).ToList();
    }

    public async Task<List<VoucherDto>> GetActiveByStoreAsync(int storeId, int? serviceId = null)
    {
        var vouchers = await _unitOfWork.VoucherRepository.GetActiveByStoreAsync(storeId, serviceId);
        return vouchers.Select(MapToDto).ToList();
    }

    public async Task<List<VoucherDto>> GetAllActiveAsync()
    {
        var vouchers = await _unitOfWork.VoucherRepository.GetAllActiveAsync();
        return vouchers.Select(MapToDto).ToList();
    }

    public async Task<VoucherDto?> GetByCodeAsync(string code)
    {
        var voucher = await _unitOfWork.VoucherRepository.GetByCodeAsync(code);
        return voucher == null ? null : MapToDto(voucher);
    }

    public async Task<List<VoucherDto>> GetActiveByServiceAsync(int serviceId, int? storeId = null)
    {
        var vouchers = await _unitOfWork.VoucherRepository.GetActiveByServiceAsync(serviceId, storeId);
        return vouchers.Select(MapToDto).ToList();
    }

    public async Task<List<ServiceVoucherHomeDto>> GetActiveServiceVouchersAsync(int? storeId = null)
    {
        var vouchers = await _unitOfWork.VoucherRepository.GetActiveServiceVouchersAsync(storeId);
        return vouchers.Select(MapToHomeDto).ToList();
    }
}