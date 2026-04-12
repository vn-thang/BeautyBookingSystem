using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Constants;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BeautyBookingSystem.API.Controllers.Public
{
    [Route("api/public/system-configs")]
    [ApiController]
    [Authorize]
    public class PublicSystemConfigController : ControllerBase
    {
        private readonly ISystemConfigService _configService;
        private readonly IBookingService _bookingService;

        public PublicSystemConfigController(
            ISystemConfigService configService,
            IBookingService bookingService)
        {
            _configService = configService;
            _bookingService = bookingService;
        }

        [HttpGet("booking-policies")]
        public async Task<IActionResult> GetBookingPolicies()
        {
            var customerIdClaim = User.FindFirst("customerId")?.Value
                               ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(customerIdClaim) || !int.TryParse(customerIdClaim, out int customerId))
                return Unauthorized();

            var data = await _bookingService.GetBookingPoliciesAsync(customerId);

            return Ok(new
            {
                success = true,
                data
            });
        }

        [HttpGet("contact-info")]
        [AllowAnonymous]
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