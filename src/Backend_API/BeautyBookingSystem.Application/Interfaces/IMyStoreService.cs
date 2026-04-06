using BeautyBookingSystem.Application.DTOs.MyStore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IMyStoreService
    {
        Task<StoreProfileDto?> GetStoreProfileAsync(int ownerId);
        Task<string?> UpdateStoreProfileAsync(int ownerId, StoreProfileDto request);
    }
}
