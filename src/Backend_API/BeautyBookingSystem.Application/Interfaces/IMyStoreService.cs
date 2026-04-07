using BeautyBookingSystem.Application.DTOs.MyStore;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IMyStoreService
    {
        // Chỉ giữ lại 2 hàm của Chủ tiệm
        Task<StoreProfileDto?> GetStoreProfileAsync(int ownerId);
        Task<string?> UpdateStoreProfileAsync(int ownerId, StoreProfileDto request);
    }
}