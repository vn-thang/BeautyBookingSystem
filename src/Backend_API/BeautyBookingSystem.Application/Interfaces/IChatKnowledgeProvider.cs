namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IChatKnowledgeProvider
    {
        Task<string> BuildContextAsync(
            int userId,
            string message,
            double? lat = null,
            double? lon = null,
            CancellationToken cancellationToken = default);
    }
}