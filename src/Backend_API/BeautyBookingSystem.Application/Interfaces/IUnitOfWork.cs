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
        IGenericRepository<StoreOperatingHour> StoreOperatingHourRepository { get; }
        IGenericRepository<User> UserRepository { get; }

        IGlobalCategoryRepository GlobalCategoryRepository { get; }
        IServiceGroupRepository ServiceGroupRepository { get; }
        IServiceRepository ServiceRepository { get; }
        IStaffRepository StaffRepository { get; }
        IBookingRepository BookingRepository { get; }
        IBookingDetailRepository BookingDetailRepository { get; }
        IPaymentRepository PaymentRepository { get; }
        IReviewRepository ReviewRepository { get; }
        IVoucherRepository VoucherRepository { get; }
        ICustomerFavoriteRepository CustomerFavoriteRepository { get; }
        ISearchHistoryRepository SearchHistories { get; }

        IGenericRepository<Notification> NotificationRepository { get; }
        IGenericRepository<WalletTransaction> WalletTransactionRepository { get; }
        IGenericRepository<SystemConfig> SystemConfigRepository { get; }
        IGenericRepository<SystemContent> SystemContentRepository { get; }
        IGenericRepository<WithdrawalRequest> WithdrawalRequestRepository { get; }
        IGenericRepository<StaffSchedule> StaffScheduleRepository { get; }
        IGenericRepository<StaffLeave> StaffLeaveRepository { get; }

        Task<int> SaveChangesAsync();
    }
}