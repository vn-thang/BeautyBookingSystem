using BeautyBookingSystem.Application.DTOs.Booking;
using BeautyBookingSystem.Application.DTOs.Staff;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IBookingService
    {
        Task<BookingResponseDto> CreateBookingAsync(
            int customerId,
            CreateBookingRequest request
        );
        Task<List<BookingListItemDto>> GetBookingsByCustomerAsync(int customerId);

        Task<BookingDetailDto?> GetBookingByIdAsync(int customerId, int bookingId);

        Task<BookingDetailDto> CancelBookingAsync(int customerId, int bookingId, string? reason);
        Task<List<AvailableStaffDto>> GetAvailableStaffAsync(GetAvailableStaffRequest request);
        Task<bool> MarkAsNoShowAsync(int storeId, int bookingId);
        Task<bool> RescheduleBookingAsync(int customerId, int bookingId, RescheduleBookingRequest request);
    }
}
