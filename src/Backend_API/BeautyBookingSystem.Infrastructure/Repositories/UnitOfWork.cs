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

        public IVoucherRepository VoucherRepository { get; }
        public IGenericRepository<User> UserRepository { get; private set; }
        public IGenericRepository<Store> StoreRepository { get; private set; }
        public IGlobalCategoryRepository GlobalCategoryRepository { get; private set; }
        public IServiceGroupRepository ServiceGroupRepository { get; private set; }
        public IServiceRepository ServiceRepository { get; private set; }
        public IBookingRepository BookingRepository { get; }
        public IBookingDetailRepository BookingDetailRepository { get; }
        public IPaymentRepository PaymentRepository { get; }
        public IStaffRepository StaffRepository { get; }
        public ICustomerFavoriteRepository CustomerFavoriteRepository { get; }
        public IGenericRepository<SystemContent> SystemContentRepository { get; private set; }
        public IReviewRepository ReviewRepository { get; }
        public ISearchHistoryRepository SearchHistories { get; }



        public UnitOfWork(AppDbContext context)
        {
            _context = context;
            UserRepository = new GenericRepository<User>(_context);
            StoreRepository = new GenericRepository<Store>(_context);
            VoucherRepository = new VoucherRepository(_context);
            GlobalCategoryRepository = new GlobalCategoryRepository(_context);
            ServiceGroupRepository = new ServiceGroupRepository(_context);
            ServiceRepository = new ServiceRepository(_context);
            BookingRepository = new BookingRepository(_context);
            BookingDetailRepository = new BookingDetailRepository(_context);
            PaymentRepository = new PaymentRepository(_context);
            StaffRepository = new StaffRepository(context);
            CustomerFavoriteRepository = new CustomerFavoriteRepository(context);
            SystemContentRepository = new GenericRepository<SystemContent>(_context);
            ReviewRepository = new ReviewRepository(_context);
            SearchHistories = new SearchHistoryRepository(_context);
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
