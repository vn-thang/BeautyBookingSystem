using BeautyBookingSystem.Application.DTOs.StoreBilling;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IStoreBillingService
    {
        Task<BookingBillDetailDto> GetBillDetailAsync(int bookingId);
    }
}