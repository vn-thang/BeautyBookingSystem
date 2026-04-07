using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Domain.Enums;
using BeautyBookingSystem.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace BeautyBookingSystem.Infrastructure.Repositories
{
    public sealed class ChatSessionRepository : IChatSessionRepository
    {
        private readonly AppDbContext _db;

        public ChatSessionRepository(AppDbContext db)
        {
            _db = db;
        }

        public async Task<ChatSession> GetOrCreateSessionAsync(
            int userId,
            string? sessionKey,
            CancellationToken cancellationToken = default)
        {
            if (!string.IsNullOrWhiteSpace(sessionKey))
            {
                var existing = await _db.ChatSessions
                    .FirstOrDefaultAsync(x => x.UserId == userId && x.SessionKey == sessionKey, cancellationToken);

                if (existing != null)
                    return existing;
            }

            var session = new ChatSession
            {
                UserId = userId,
                SessionKey = Guid.NewGuid().ToString("N"),
                CreatedAt = DateTime.UtcNow,
                LastActivityAt = DateTime.UtcNow
            };

            _db.ChatSessions.Add(session);
            await _db.SaveChangesAsync(cancellationToken);
            return session;
        }

        public Task<ChatSession?> GetBySessionKeyAsync(
            int userId,
            string sessionKey,
            CancellationToken cancellationToken = default)
        {
            return _db.ChatSessions
                .FirstOrDefaultAsync(x => x.UserId == userId && x.SessionKey == sessionKey, cancellationToken);
        }

        public async Task<List<ChatMessage>> GetRecentMessagesAsync(
            int chatSessionId,
            int take = 8,
            CancellationToken cancellationToken = default)
        {
            return await _db.ChatMessages
                .Where(x => x.ChatSessionId == chatSessionId)
                .OrderByDescending(x => x.CreatedAt)
                .Take(take)
                .OrderBy(x => x.CreatedAt)
                .ToListAsync(cancellationToken);
        }

        public async Task AddMessageAsync(
            int chatSessionId,
            ChatMessageRole role,
            string content,
            string? toolName = null,
            string? metadataJson = null,
            CancellationToken cancellationToken = default)
        {
            _db.ChatMessages.Add(new ChatMessage
            {
                ChatSessionId = chatSessionId,
                Role = role,
                Content = content,
                ToolName = toolName,
                MetadataJson = metadataJson,
                CreatedAt = DateTime.UtcNow
            });

            var session = await _db.ChatSessions.FirstAsync(x => x.Id == chatSessionId, cancellationToken);
            session.LastActivityAt = DateTime.UtcNow;
        }

        public Task SaveChangesAsync(CancellationToken cancellationToken = default)
            => _db.SaveChangesAsync(cancellationToken);
    }
}