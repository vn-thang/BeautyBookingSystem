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
        Task<List<StoreBookingListDto>> GetBookingsAsync(string? status = null);

        Task<StoreBookingDetailDto> GetBookingDetailAsync(int bookingId);

        Task<List<AvailableStaffDto>> GetAvailableStaffsAsync(DateTime date, TimeSpan startTime, TimeSpan endTime);

        Task<bool> AssignStaffAndConfirmAsync(int bookingId, AssignStaffRequest request);

        Task<bool> UpdateStatusAsync(int bookingId, UpdateBookingStatusRequest request);
    }
}
