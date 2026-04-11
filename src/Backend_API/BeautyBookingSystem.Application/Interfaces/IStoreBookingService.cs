using BeautyBookingSystem.Application.DTOs.Booking;
using BeautyBookingSystem.Application.DTOs.StoreBooking;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IStoreBookingService
    {
        Task<List<StoreBookingListDto>> GetBookingsAsync(string? status = null, int? staffId = null, DateTime? startDate = null, DateTime? endDate = null);

        Task<StoreBookingDetailDto> GetBookingDetailAsync(int bookingId);

        Task<List<AvailableStaffDto>> GetAvailableStaffsAsync(DateTime date, TimeSpan startTime, TimeSpan endTime,   int? excludeBookingId = null);

        Task<bool> AssignStaffAndConfirmAsync(int bookingId, AssignStaffRequest request);

        Task<bool> UpdateStatusAsync(int bookingId, UpdateBookingStatusRequest request);
        Task<BookingResponseDto> CreateStoreBookingAsync(CreateStoreBookingRequest request);
       Task<List<TimeSlotDto>> GetAvailableTimeSlotsAsync(DateTime date, int totalDurationMinutes);
    }
}
