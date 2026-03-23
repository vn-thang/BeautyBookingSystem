using BeautyBookingSystem.Application.Common;
using BeautyBookingSystem.Application.DTOs.Store;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IStoreService
    {
        Task<List<StoreListDto>> GetAllStoresAsync();
        Task<PagedResult<StoreCardDto>> GetStoresByCategoryAsync(StoreQueryParams p);
        Task<PagedResult<StoreCardDto>> GetStoresByGroupAsync(StoreQueryParams p);
        Task<StoreDetailDto?> GetStoreByIdAsync(int storeId);
        Task<StoreProfileDto?> GetStoreProfileAsync(int ownerId);
        Task<string?> UpdateStoreProfileAsync(int ownerId, StoreProfileDto request);
    }
}
