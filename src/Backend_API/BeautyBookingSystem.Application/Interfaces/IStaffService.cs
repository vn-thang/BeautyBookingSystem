using BeautyBookingSystem.Application.DTOs.Staff;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IStaffService
    {
        Task<List<StaffDtos>> GetAllByCurrentStoreAsync(bool onlyActive = true);

        Task<StaffDtos> GetByIdAsync(int id);
        Task<StaffDtos> CreateAsync(CreateStaffRequest request);
        Task<bool> UpdateAsync(int id, UpdateStaffRequest request);
        Task<bool> DeleteAsync(int id);
    }
}
