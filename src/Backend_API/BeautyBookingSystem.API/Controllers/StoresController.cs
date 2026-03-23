using BeautyBookingSystem.Application.DTOs.Store;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BeautyBookingSystem.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class StoresController : ControllerBase
    {
        private readonly IStoreService _storeService;

        public StoresController(IStoreService storeService)
        {
            _storeService = storeService;
        }
        [HttpGet]
        public async Task<IActionResult> GetAllStores()
        {
            var result = await _storeService.GetAllStoresAsync();
            return Ok(result);
        }

        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetStoreById(int id)
        {
            var result = await _storeService.GetStoreByIdAsync(id);

            if (result == null)
                return NotFound();

            return Ok(result);
        }

        [HttpGet("by-category")]
        public async Task<IActionResult> GetStores([FromQuery] StoreQueryParams query)
        {
            var result = await _storeService.GetStoresByCategoryAsync(query);

            return Ok(result);
        }
        [HttpGet("by-group")]
        public async Task<IActionResult> GetStoresByGroup([FromQuery] StoreQueryParams query)
        {
            var result = await _storeService.GetStoresByGroupAsync(query);
            return Ok(result);
        }

        [HttpGet("profile")]
        public async Task<IActionResult> GetProfile()
        {
            var ownerId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "");
            var result = await _storeService.GetStoreProfileAsync(ownerId);
            return result != null ? Ok(result) : NotFound();
        }
        [Authorize(Roles = "StoreOwner")]
        [HttpPut("profile")]
        public async Task<IActionResult> UpdateProfile([FromBody] StoreProfileDto request)
        {
            var ownerId = int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier) ?? "");
            var error = await _storeService.UpdateStoreProfileAsync(ownerId, request);

            if (error != null) return BadRequest(new { message = error });
            return Ok(new { message = "Cập nhật thành công!" });
        }
    }
}
