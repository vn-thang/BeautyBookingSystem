using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BeautyBookingSystem.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class HomeController : ControllerBase
    {
        private readonly IHomeService _homeService;

        public HomeController(IHomeService homeService)
        {
            _homeService = homeService;
        }

        [HttpGet]
        public async Task<IActionResult> GetHome(
            [FromQuery] double? lat,
            [FromQuery] double? lon)
        {
            var userId = User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            Guid? uid = null;

            if (Guid.TryParse(userId, out var parsed))
            {
                uid = parsed;
            }

            var result = await _homeService.GetHomeDataAsync(uid, lat, lon);

            return Ok(result);
        }
    }
}
