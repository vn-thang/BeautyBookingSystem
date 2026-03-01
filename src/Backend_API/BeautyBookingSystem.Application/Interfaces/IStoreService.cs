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
        Task<StoreProfileDto?> GetStoreProfileAsync(int ownerId);
        Task<string?> UpdateStoreProfileAsync(int ownerId, StoreProfileDto request);
    }
}
