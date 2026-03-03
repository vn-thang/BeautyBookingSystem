using BeautyBookingSystem.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IUnitOfWork : IDisposable
    {
        IGenericRepository<Store> StoreRepository { get; }
        IGenericRepository<User> UserRepository { get; }
        IGenericRepository<GlobalCategory> GlobalCategoryRepository { get; }
        IGenericRepository<Staff> StaffRepository { get; }
        IGenericRepository<ServiceGroup> ServiceGroupRepository { get; }
        IGenericRepository<Service> ServiceRepository { get; }
        IGenericRepository<Booking> BookingRepository { get; }
        IGenericRepository<BookingDetail> BookingDetailRepository { get; }
        IGenericRepository<Payment> PaymentRepository { get; }
        IGenericRepository<Review> ReviewRepository { get; }
        IGenericRepository<Voucher> VoucherRepository { get; }
        IGenericRepository<Notification> NotificationRepository { get; }
        Task<int> SaveChangesAsync();
    }
}
