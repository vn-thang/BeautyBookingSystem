using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BeautyBookingSystem.Api.Controllers
{
    [ApiController]
    [Route("api/customer-favorites")]
    [Authorize(Roles ="Customer")]
    public class CustomerFavoritesController : ControllerBase
    {
        private readonly ICustomerFavoriteService _favoriteService;

        public CustomerFavoritesController(ICustomerFavoriteService favoriteService)
        {
            _favoriteService = favoriteService;
        }

        [HttpGet("home")]
        public async Task<IActionResult> GetHomeFavorites(
    [FromQuery] double? latitude,
    [FromQuery] double? longitude)
        {
            var customerId = GetCustomerId();

            var favoriteStores = await _favoriteService
                .GetFavoriteStoresAsync(customerId, latitude, longitude);

            var favoriteServices = await _favoriteService
                .GetFavoriteServicesAsync(customerId);

            return Ok(new
            {
                favoriteStores,
                favoriteServices
            });
        }

        [HttpPost("store/{storeId:int}")]
        public async Task<IActionResult> FavoriteStore(int storeId)
        {
            var customerId = GetCustomerId();
            await _favoriteService.FavoriteStoreAsync(customerId, storeId);
            return Ok(new { message = "Đã thêm cửa hàng vào yêu thích." });
        }

        [HttpDelete("store/{storeId:int}")]
        public async Task<IActionResult> UnfavoriteStore(int storeId)
        {
            var customerId = GetCustomerId();
            await _favoriteService.UnfavoriteStoreAsync(customerId, storeId);
            return Ok(new { message = "Đã bỏ yêu thích cửa hàng." });
        }

        [HttpPost("service/{serviceId:int}")]
        public async Task<IActionResult> FavoriteService(int serviceId)
        {
            var customerId = GetCustomerId();
            await _favoriteService.FavoriteServiceAsync(customerId, serviceId);
            return Ok(new { message = "Đã thêm dịch vụ vào yêu thích." });
        }

        [HttpDelete("service/{serviceId:int}")]
        public async Task<IActionResult> UnfavoriteService(int serviceId)
        {
            var customerId = GetCustomerId();
            await _favoriteService.UnfavoriteServiceAsync(customerId, serviceId);
            return Ok(new { message = "Đã bỏ yêu thích dịch vụ." });
        }

        private int GetCustomerId()
        {
            var claim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(claim, out var customerId))
                throw new UnauthorizedAccessException("Không lấy được CustomerId từ token.");

            return customerId;
        }
    }
}