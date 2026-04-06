using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers.Public
{
    [Route("api/public/system-configs")]
    [ApiController]
    [AllowAnonymous]     
    public class PublicSystemConfigController : ControllerBase
    {
        private readonly ISystemConfigService _configService;

        public PublicSystemConfigController(ISystemConfigService configService)
        {
            _configService = configService;
        }

        [HttpGet("contact-info")]
        public async Task<IActionResult> GetContactInfo()
        {
            var hotline = await _configService.GetValueAsync<string>(SystemConfigKeys.Hotline);
            var email = await _configService.GetValueAsync<string>(SystemConfigKeys.SupportEmail);
            return Ok(new
            {
                Hotline = string.IsNullOrWhiteSpace(hotline) ? "Đang cập nhật" : hotline,
                Email = string.IsNullOrWhiteSpace(email) ? "Đang cập nhật" : email
            });
        }
    }
}