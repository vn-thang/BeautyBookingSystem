using BeautyBookingSystem.Application.DTOs.StoreCustomer;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace BeautyBookingSystem.Application.Services
{
    public class StoreCustomerService : IStoreCustomerService
    {
        private readonly IUnitOfWork _unitOfWork;
        public StoreCustomerService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<List<CustomerListDto>> GetStoreCustomersAsync(int storeId, string? searchTerm = null)
        {
            var query = _unitOfWork.UserRepository.GetQueryable()
                .Where(u => u.Bookings.Any(b => b.StoreId == storeId));

            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                string term = searchTerm.ToLower().Trim();
                query = query.Where(u => u.FullName.ToLower().Contains(term) || u.Phone.Contains(term));
            }

            var customers = await query
                .Select(u => new CustomerListDto
                {
                    CustomerId = u.Id,
                    FullName = u.FullName,
                    Phone = u.Phone,
                    AvatarUrl = u.AvatarUrl,
                    TotalVisits = u.Bookings.Count(b => b.StoreId == storeId && b.Status == BookingStatus.Completed),
                    TotalSpent = u.Bookings
                        .Where(b => b.StoreId == storeId && b.Status == BookingStatus.Completed)
                        .Sum(b => b.FinalPrice)
                })
                .OrderByDescending(c => c.TotalVisits) 
                .ToListAsync();

            return customers;
        }
        public async Task<CustomerProfileDto?> GetCustomerProfileAsync(int storeId, int customerId)
        {
            var profile = await _unitOfWork.UserRepository.GetQueryable()
                .Where(u => u.Id == customerId)
                .Select(u => new CustomerProfileDto
                {
                    CustomerId = u.Id,
                    FullName = u.FullName,
                    Phone = u.Phone,
                    AvatarUrl = u.AvatarUrl,
                    TotalVisits = u.Bookings.Count(b => b.StoreId == storeId && b.Status == BookingStatus.Completed),
                    TotalSpent = u.Bookings.Where(b => b.StoreId == storeId && b.Status == BookingStatus.Completed).Sum(b => b.FinalPrice),
                    TotalCancelled = u.Bookings.Count(b => b.StoreId == storeId && b.Status == BookingStatus.Cancelled)
                })
                .FirstOrDefaultAsync();

            if (profile == null) return null;
            var history = await _unitOfWork.BookingRepository.GetQueryable()
                .Where(b => b.StoreId == storeId && b.CustomerId == customerId && b.Status == BookingStatus.Completed)
                .SelectMany(b => b.BookingDetails)
                .OrderByDescending(bd => bd.AppointmentDate)
                .Select(bd => new CustomerServiceHistoryDto
                {
                    BookingId = bd.BookingId,
                    AppointmentDate = bd.AppointmentDate,
                    StartTime = bd.StartTime,
                    ServiceName = bd.Service.Name, 
                    StaffName = bd.Staff != null ? bd.Staff.FullName : "Không chọn thợ",
                    Price = bd.Price
                })
                .ToListAsync();

            profile.ServiceHistories = history;

            return profile;
        }
    }
}