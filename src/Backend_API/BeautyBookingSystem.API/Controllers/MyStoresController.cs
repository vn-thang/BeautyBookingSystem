using BeautyBookingSystem.Application.DTOs.MyStore;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BeautyBookingSystem.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "StoreOwner")]
    public class MyStoresController : ControllerBase
    {
        private readonly IMyStoreService _storeService;

        public MyStoresController(IMyStoreService storeService)
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
            var customerId = GetCurrentCustomerId();
            var result = await _storeService.GetStoreByIdAsync(id, customerId);

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
            var claimValue = User.FindFirstValue(ClaimTypes.NameIdentifier);

            if (string.IsNullOrEmpty(claimValue) || !int.TryParse(claimValue, out var ownerId))
            {
                return Unauthorized(new { message = "Token không hợp lệ hoặc không tìm thấy ID người dùng." });
            }
            var result = await _storeService.GetStoreProfileAsync(ownerId);

            return result != null ? Ok(result) : NotFound(new { message = "Không tìm thấy hồ sơ cửa hàng." });
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

        private int? GetCurrentCustomerId()
        {
            var claim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            return int.TryParse(claim, out var customerId) ? customerId : null;
        }
    }
}