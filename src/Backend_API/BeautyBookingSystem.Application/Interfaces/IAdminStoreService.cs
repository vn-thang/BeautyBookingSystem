using BeautyBookingSystem.Application.DTOs.AdminStore;
using BeautyBookingSystem.Application.DTOs.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IAdminStoreService
    {
        Task<PagedResponse<StoreAdminDto>> GetStoresAsync(StoreFilterRequest request);
        Task<StoreAdminDetailDto?> GetStoreByIdAsync(int id);
        Task<bool> ApproveStoreAsync(int id, ApproveStoreRequest request);
        Task<bool> ChangeStoreStatusAsync(int id, UpdateStoreStatusRequest request);
        Task<IEnumerable<StoreDropdownDto>> GetStoresForDropdownAsync();
        Task<bool> UpdateStoreFeeConfigAsync(int id, UpdateStoreFeeConfigRequest request);
    }
}
