using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Application.Interfaces.Repositories;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Infrastructure.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Infrastructure.Repositories
{
    public class UnitOfWork : IUnitOfWork
    {
        private readonly AppDbContext _context;
        public IGenericRepository<User> UserRepository { get; private set; }
        public IGenericRepository<Store> StoreRepository { get; private set; }
        public IGenericRepository<StoreOperatingHour> StoreOperatingHourRepository { get; private set; }
        public IGlobalCategoryRepository GlobalCategoryRepository { get; private set; }
        public IServiceGroupRepository ServiceGroupRepository { get; private set; }
        public IServiceRepository ServiceRepository { get; private set; }
        public IStaffRepository StaffRepository { get; private set; }
        public IBookingRepository BookingRepository { get; private set; }
        public IBookingDetailRepository BookingDetailRepository { get; private set; }
        public IPaymentRepository PaymentRepository { get; private set; }
        public IReviewRepository ReviewRepository { get; private set; }
        public IVoucherRepository VoucherRepository { get; private set; }
        public ICustomerFavoriteRepository CustomerFavoriteRepository { get; private set; }
        public ISearchHistoryRepository SearchHistories { get; private set; }
        public IGenericRepository<Notification> NotificationRepository { get; private set; }
        public IGenericRepository<WalletTransaction> WalletTransactionRepository { get; private set; }
        public IGenericRepository<SystemConfig> SystemConfigRepository { get; private set; }
        public IGenericRepository<SystemContent> SystemContentRepository { get; private set; }
        public IGenericRepository<WithdrawalRequest> WithdrawalRequestRepository { get; private set; }
        public IGenericRepository<StaffSchedule> StaffScheduleRepository { get; private set; }
        public IGenericRepository<StaffLeave> StaffLeaveRepository { get; private set; }
        public IGenericRepository<StoreBanner> StoreBannerRepository { get; private set; }
        public UnitOfWork(AppDbContext context)
        {
            _context = context;
            UserRepository = new GenericRepository<User>(_context);
            StoreRepository = new GenericRepository<Store>(_context);
            StoreOperatingHourRepository = new GenericRepository<StoreOperatingHour>(_context);
            GlobalCategoryRepository = new GlobalCategoryRepository(_context);
            ServiceGroupRepository = new ServiceGroupRepository(_context);
            ServiceRepository = new ServiceRepository(_context);
            StaffRepository = new StaffRepository(_context);
            BookingRepository = new BookingRepository(_context);
            BookingDetailRepository = new BookingDetailRepository(_context);
            PaymentRepository = new PaymentRepository(_context);
            ReviewRepository = new ReviewRepository(_context);
            VoucherRepository = new VoucherRepository(_context);
            CustomerFavoriteRepository = new CustomerFavoriteRepository(_context);
            SearchHistories = new SearchHistoryRepository(_context);

            NotificationRepository = new GenericRepository<Notification>(_context);
            WalletTransactionRepository = new GenericRepository<WalletTransaction>(_context);
            SystemConfigRepository = new GenericRepository<SystemConfig>(_context);
            SystemContentRepository = new GenericRepository<SystemContent>(_context);
            WithdrawalRequestRepository = new GenericRepository<WithdrawalRequest>(_context);
            StaffScheduleRepository = new GenericRepository<StaffSchedule>(_context);
            StaffLeaveRepository = new GenericRepository<StaffLeave>(_context);
            StoreBannerRepository = new GenericRepository<StoreBanner>(_context);
        }

        public async Task<int> SaveChangesAsync()
        {
            return await _context.SaveChangesAsync();
        }

        public void Dispose()
        {
            _context.Dispose();
        }
    }
}