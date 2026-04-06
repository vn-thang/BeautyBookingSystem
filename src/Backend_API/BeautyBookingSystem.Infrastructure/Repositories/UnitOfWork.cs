using BeautyBookingSystem.Application.Interfaces;
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
        public IGenericRepository<GlobalCategory> GlobalCategoryRepository { get; private set; }
        public IGenericRepository<Staff> StaffRepository { get; private set; }
        public IGenericRepository<ServiceGroup> ServiceGroupRepository { get; private set; }
        public IGenericRepository<Service> ServiceRepository { get; private set; }
        public IGenericRepository<Booking> BookingRepository { get; private set; }
        public IGenericRepository<BookingDetail> BookingDetailRepository { get; private set; }
        public IGenericRepository<Payment> PaymentRepository { get; private set; }
        public IGenericRepository<Review> ReviewRepository { get; private set; }
        public IGenericRepository<Voucher> VoucherRepository { get; private set; }
        public IGenericRepository<Notification> NotificationRepository { get; private set; }
        public IGenericRepository<WalletTransaction> WalletTransactionRepository { get; private set; }
        public IGenericRepository<SystemConfig> SystemConfigRepository { get; private set; }
        public IGenericRepository<SystemContent> SystemContentRepository { get; private set; }
         public IGenericRepository<WithdrawalRequest> WithdrawalRequestRepository { get; private set; }


     

        public UnitOfWork(AppDbContext context)
        {
            _context = context;
            UserRepository = new GenericRepository<User>(_context);
            StoreRepository = new GenericRepository<Store>(_context);
            StoreOperatingHourRepository = new GenericRepository<StoreOperatingHour>(_context);
            GlobalCategoryRepository = new GenericRepository<GlobalCategory>(_context);
            StaffRepository = new GenericRepository<Staff>(_context);
            ServiceGroupRepository = new GenericRepository<ServiceGroup>(_context);
            ServiceRepository = new GenericRepository<Service>(_context);
            BookingRepository = new GenericRepository<Booking>(_context);
            BookingDetailRepository = new GenericRepository<BookingDetail>(_context);
            PaymentRepository = new GenericRepository<Payment>(_context);
            ReviewRepository = new GenericRepository<Review>(_context);
            VoucherRepository = new GenericRepository<Voucher>(_context);
            NotificationRepository = new GenericRepository<Notification>(_context);
            WalletTransactionRepository = new GenericRepository<WalletTransaction>(_context);
            SystemConfigRepository = new GenericRepository<SystemConfig>(_context);
            SystemContentRepository = new GenericRepository<SystemContent>(_context);
            WithdrawalRequestRepository = new GenericRepository<WithdrawalRequest>(_context);
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
