using BeautyBookingSystem.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IVoucherRepository : IGenericRepository<Voucher>
    {
        Task<List<Voucher>> GetActiveAsync();
    }
}
