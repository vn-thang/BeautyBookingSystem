using BeautyBookingSystem.Application.DTOs.MyStore;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BeautyBookingSystem.API.Controllers
{
    [Route("api/store/my-store")] // Route rạch ròi cho chủ tiệm
    [ApiController]
    [Authorize(Roles = "StoreOwner")]
    public class MyStoreController : ControllerBase
    {
        private readonly IMyStoreService _storeService;

        public MyStoreController(IMyStoreService storeService)
        {
            _storeService = storeService;
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

        [HttpPut("profile")]
        public async Task<IActionResult> UpdateProfile([FromBody] StoreProfileDto request)
        {
            var claimValue = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(claimValue) || !int.TryParse(claimValue, out var ownerId))
            {
                return Unauthorized();
            }

            var error = await _storeService.UpdateStoreProfileAsync(ownerId, request);

            if (error != null) return BadRequest(new { message = error });
            return Ok(new { message = "Cập nhật thành công!" });
        }
    }
}