using BeautyBookingSystem.Application.Interfaces.Repositories;
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
        IVoucherRepository VoucherRepository { get; }
        IGlobalCategoryRepository GlobalCategoryRepository { get; }
        IServiceGroupRepository ServiceGroupRepository { get; }
        IServiceRepository ServiceRepository { get; }
        IBookingRepository BookingRepository { get; }
        IBookingDetailRepository BookingDetailRepository { get; }
        IPaymentRepository PaymentRepository { get; }
        IStaffRepository StaffRepository { get; }
        ICustomerFavoriteRepository CustomerFavoriteRepository { get; }
        IGenericRepository<SystemContent> SystemContentRepository { get; }
        IReviewRepository ReviewRepository { get; }
        ISearchHistoryRepository SearchHistories { get; }
        Task<int> SaveChangesAsync();
    }
}
