using BeautyBookingSystem.Application.DTOs.CustomerStore;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using System.Threading.Tasks;

namespace BeautyBookingSystem.API.Controllers
{
    [Route("api/customer/stores")] 
    [ApiController]
    public class PublicStoresController : ControllerBase
    {
        private readonly IPublicStoreService _publicStoreService;

        public PublicStoresController(IPublicStoreService publicStoreService)
        {
            _publicStoreService = publicStoreService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAllStores()
        {
            var result = await _publicStoreService.GetAllStoresAsync();
            return Ok(result);
        }

        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetStoreById(int id)
        {
            var customerId = GetCurrentUserId();
            var result = await _publicStoreService.GetStoreByIdAsync(id, customerId);

            if (result == null)
                return NotFound();

            return Ok(result);
        }

        [HttpGet("by-category")]
        public async Task<IActionResult> GetByCategory([FromQuery] StoreQueryParams query)
        {
            var result = await _publicStoreService.GetStoresByCategoryAsync(query);
            return Ok(result);
        }

        [HttpGet("by-group")]
        public async Task<IActionResult> GetByGroup([FromQuery] StoreQueryParams query)
        {
            var result = await _publicStoreService.GetStoresByGroupAsync(query);
            return Ok(result);
        }

        private int? GetCurrentUserId()
        {
            var claim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            return int.TryParse(claim, out var userId) ? userId : null;
        }
    }
}