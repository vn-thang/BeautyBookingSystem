using BeautyBookingSystem.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IStaffRepository : IGenericRepository<Staff>
    {
        Task<List<Staff>> GetByStoreIdAsync(int storeId);
        Task<List<Staff>> GetStaffsWithSchedulesAndLeavesAsync(int storeId);
    }
}
