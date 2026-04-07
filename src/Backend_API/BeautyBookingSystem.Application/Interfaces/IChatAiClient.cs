namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IChatAiClient
    {
        Task<string> GenerateReplyAsync(
            string message,
            string context,
            string memory,
            CancellationToken cancellationToken = default);
    }
}