using BeautyBookingSystem.Application.DTOs.StoreVoucher;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IStoreVoucherService
    {
        Task<List<VoucherDto>> GetAllVouchersAsync();
        Task<VoucherDto> GetVoucherByIdAsync(int id);
        Task<VoucherDto> CreateVoucherAsync(CreateVoucherRequest request);
        Task<bool> UpdateVoucherAsync(int id, UpdateVoucherRequest request);
        Task<bool> DeleteVoucherAsync(int id);
    } 
}
