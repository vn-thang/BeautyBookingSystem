using BeautyBookingSystem.Application.DTOs.AdminBooking;
using BeautyBookingSystem.Application.DTOs.Common;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IAdminBookingService
    {
        Task<PagedResponse<AdminBookingListDto>> GetBookingsAsync(AdminBookingFilterRequest request);
        Task<AdminBookingDetailDto?> GetBookingByIdAsync(int id);
        Task<bool> CancelBookingAsync(int id, AdminCancelBookingRequest request);
    }
}