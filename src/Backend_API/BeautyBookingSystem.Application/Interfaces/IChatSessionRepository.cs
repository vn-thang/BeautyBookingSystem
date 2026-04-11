using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Domain.Enums;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IChatSessionRepository
    {
        Task<ChatSession> GetOrCreateSessionAsync(
            int userId,
            string? sessionKey,
            CancellationToken cancellationToken = default);

        Task<ChatSession?> GetBySessionKeyAsync(
            int userId,
            string sessionKey,
            CancellationToken cancellationToken = default);

        Task<List<ChatMessage>> GetRecentMessagesAsync(
            int chatSessionId,
            int take = 8,
            CancellationToken cancellationToken = default);

        Task AddMessageAsync(
            int chatSessionId,
            ChatMessageRole role,
            string content,
            string? toolName = null,
            string? metadataJson = null,
            CancellationToken cancellationToken = default);

        Task SaveChangesAsync(CancellationToken cancellationToken = default);
    }
}