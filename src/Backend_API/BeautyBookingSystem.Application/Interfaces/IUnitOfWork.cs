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
        // 1. CÁC REPOSITORY DÙNG CHUNG (Của cả 2 bên)
        IGenericRepository<Store> StoreRepository { get; }
        IGenericRepository<StoreOperatingHour> StoreOperatingHourRepository { get; }
        IGenericRepository<User> UserRepository { get; }

        // 2. CÁC REPOSITORY CHUYÊN BIỆT (Giữ nguyên của Quan để không chết code App Khách)
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

        // 3. CÁC REPOSITORY GENERIC MỚI THÊM VÀO (Từ cấu trúc develop của bạn)
        IGenericRepository<Notification> NotificationRepository { get; }
        IGenericRepository<WalletTransaction> WalletTransactionRepository { get; }
        IGenericRepository<SystemConfig> SystemConfigRepository { get; }
        IGenericRepository<SystemContent> SystemContentRepository { get; }
        IGenericRepository<WithdrawalRequest> WithdrawalRequestRepository { get; }

        Task<int> SaveChangesAsync();
    }
}