using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IUnitOfWork : IDisposable
    {
        // Khai báo các Repository cụ thể ở đây (sau này dùng)
        // IUserRepository Users { get; }
        // IStoreRepository Stores { get; }
        IVoucherRepository Vouchers { get; }
        Task<int> SaveChangesAsync();
    }
}
