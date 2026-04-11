using System.Text;
using BeautyBookingSystem.Application.DTOs.Chat;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Enums;

namespace BeautyBookingSystem.Application.Services
{
    public sealed class ChatAssistantService : IChatAssistantService
    {
        private const string ContextTooLargeMarker = "=== CONTEXT_TOO_LARGE ===";

        private readonly IChatKnowledgeProvider _knowledgeProvider;
        private readonly IChatAiClient _aiClient;
        private readonly IChatSessionRepository _sessionRepository;

        public ChatAssistantService(
            IChatKnowledgeProvider knowledgeProvider,
            IChatAiClient aiClient,
            IChatSessionRepository sessionRepository)
        {
            _knowledgeProvider = knowledgeProvider;
            _aiClient = aiClient;
            _sessionRepository = sessionRepository;
        }

        public async Task<ChatResponseDto> SendAsync(
            int userId,
            ChatRequestDto request,
            CancellationToken cancellationToken = default)
        {
            var session = await _sessionRepository.GetOrCreateSessionAsync(
                userId,
                request.SessionKey,
                cancellationToken);

            await _sessionRepository.AddMessageAsync(
                session.Id,
                ChatMessageRole.User,
                request.Message,
                cancellationToken: cancellationToken);

            var recent = await _sessionRepository.GetRecentMessagesAsync(
                session.Id,
                take: 5,
                cancellationToken: cancellationToken);

            var memory = BuildMemory(recent);

            var context = await _knowledgeProvider.BuildContextAsync(
                userId,
                request.Message,
                request.UserLat,
                request.UserLng,
                cancellationToken);

            if (context.Contains(ContextTooLargeMarker, StringComparison.Ordinal))
            {
                var reply = "Cuộc trò chuyện đã dài rồi. Bạn hãy bấm **Chat mới** để mình hỗ trợ tiếp chính xác hơn nhé.";

                await _sessionRepository.AddMessageAsync(
                    session.Id,
                    ChatMessageRole.Assistant,
                    reply,
                    cancellationToken: cancellationToken);

                await _sessionRepository.SaveChangesAsync(cancellationToken);

                return new ChatResponseDto
                {
                    SessionKey = session.SessionKey,
                    Reply = reply
                };
            }

            var replyText = await _aiClient.GenerateReplyAsync(
                request.Message,
                context,
                memory,
                cancellationToken);

            await _sessionRepository.AddMessageAsync(
                session.Id,
                ChatMessageRole.Assistant,
                replyText,
                cancellationToken: cancellationToken);

            await _sessionRepository.SaveChangesAsync(cancellationToken);

            return new ChatResponseDto
            {
                SessionKey = session.SessionKey,
                Reply = replyText
            };
        }

        public async Task<List<ChatMessageDto>> GetHistoryAsync(
            int userId,
            string sessionKey,
            CancellationToken cancellationToken = default)
        {
            var session = await _sessionRepository.GetBySessionKeyAsync(userId, sessionKey, cancellationToken);
            if (session == null)
                return new List<ChatMessageDto>();

            var messages = await _sessionRepository.GetRecentMessagesAsync(session.Id, 100, cancellationToken);

            return messages
                .OrderBy(x => x.CreatedAt)
                .Select(x => new ChatMessageDto
                {
                    Role = x.Role.ToString(),
                    Content = x.Content,
                    CreatedAt = x.CreatedAt
                })
                .ToList();
        }

        private static string BuildMemory(IReadOnlyList<BeautyBookingSystem.Domain.Entities.ChatMessage> messages)
        {
            var sb = new StringBuilder();

            foreach (var m in messages.TakeLast(4))
            {
                sb.AppendLine($"{m.Role}: {m.Content}");
            }

            return TrimTo(sb.ToString(), 1200);
        }

        private static string TrimTo(string? value, int maxChars)
        {
            if (string.IsNullOrWhiteSpace(value))
                return string.Empty;

            var text = value.Trim();
            return text.Length <= maxChars ? text : text[..maxChars];
        }
    }
}