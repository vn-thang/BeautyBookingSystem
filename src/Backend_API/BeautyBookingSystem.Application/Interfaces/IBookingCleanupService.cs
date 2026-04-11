namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IBookingCleanupService
    {
        Task CancelExpiredPendingBookingsAsync();
    }
}