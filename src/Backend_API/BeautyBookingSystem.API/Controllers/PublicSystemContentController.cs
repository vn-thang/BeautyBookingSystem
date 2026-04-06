using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers.Public
{
    [Route("api/public/system-contents")]
    [ApiController]
    [AllowAnonymous] 
    public class PublicSystemContentController : ControllerBase
    {
        private readonly ISystemContentService _contentService;

        public PublicSystemContentController(ISystemContentService contentService)
        {
            _contentService = contentService;
        }

        [HttpGet("type/{type}")]
        public async Task<IActionResult> GetByType(SystemContentType type)
        {
            var result = await _contentService.GetByTypeForPublicAsync(type);
            if (result == null) return NotFound("Nội dung đang được cập nhật."); 
            return Ok(result);
        }
    }
}