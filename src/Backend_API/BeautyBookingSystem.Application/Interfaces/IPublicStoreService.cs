using BeautyBookingSystem.Application.Common;
using BeautyBookingSystem.Application.DTOs.CustomerStore; 
using System.Collections.Generic;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IPublicStoreService
    {
        Task<List<StoreListDto>> GetAllStoresAsync();
        Task<PagedResult<StoreCardDto>> GetStoresByCategoryAsync(StoreQueryParams p);
        Task<PagedResult<StoreCardDto>> GetStoresByGroupAsync(StoreQueryParams p);
        Task<StoreDetailDto?> GetStoreByIdAsync(int storeId, int? customerId = null);
    }
}