using BeautyBookingSystem.Application.DTOs.StoreStaff;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IStoreStaffService
    {
        Task<List<StaffDtos>> GetAllByCurrentStoreAsync(bool onlyActive = true);

        Task<StaffDtos> GetByIdAsync(int id);
        Task<StaffDtos> CreateAsync(CreateStaffRequest request);
        Task<bool> UpdateAsync(int id, UpdateStaffRequest request);
        Task<bool> DeleteAsync(int id);
        Task<List<StaffScheduleDto>> GetSchedulesAsync(int staffId);
        Task<bool> UpdateSchedulesAsync(int staffId, List<UpdateStaffScheduleRequest> requests);
        Task<List<StaffLeaveDto>> GetLeavesAsync(int staffId);
        Task<bool> CreateLeaveAsync(int staffId, CreateStaffLeaveRequest request);
        Task<bool> DeleteLeaveAsync(int staffId, int leaveId);
    }
}
