using BeautyBookingSystem.Application.DTOs.Chat;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IChatAssistantService
    {
        Task<ChatResponseDto> SendAsync(
            int userId,
            ChatRequestDto request,
            CancellationToken cancellationToken = default);

        Task<List<ChatMessageDto>> GetHistoryAsync(
            int userId,
            string sessionKey,
            CancellationToken cancellationToken = default);
    }
}