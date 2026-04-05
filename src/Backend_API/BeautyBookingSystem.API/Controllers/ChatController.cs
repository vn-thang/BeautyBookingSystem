using System.Security.Claims;
using BeautyBookingSystem.Application.DTOs.Chat;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers
{
    [ApiController]
    [Route("api/chat")]
    [Authorize]
    public class ChatController : ControllerBase
    {
        private readonly IChatAssistantService _chatAssistantService;

        public ChatController(IChatAssistantService chatAssistantService)
        {
            _chatAssistantService = chatAssistantService;
        }

        [HttpPost("send")]
        public async Task<ActionResult<ChatResponseDto>> Send(
            [FromBody] ChatRequestDto request,
            CancellationToken cancellationToken)
        {
            var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
            var result = await _chatAssistantService.SendAsync(userId, request, cancellationToken);
            return Ok(result);
        }

        [HttpGet("history/{sessionKey}")]
        public async Task<ActionResult<List<ChatMessageDto>>> History(
            string sessionKey,
            CancellationToken cancellationToken)
        {
            var userId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
            var result = await _chatAssistantService.GetHistoryAsync(userId, sessionKey, cancellationToken);
            return Ok(result);
        }
    }
}