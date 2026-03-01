using BeautyBookingSystem.Application.DTOs;
using BeautyBookingSystem.Application.DTOs.Common;
using BeautyBookingSystem.Application.Services;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class StoresController : ControllerBase
    {
        private readonly StoreService _service;

        public StoresController(StoreService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<IActionResult> GetApproved()
        {
            var result = await _service.GetApprovedAsync();
            return Ok(ApiResponse<List<StoreDto>>.Ok(result));
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetDetail(int id)
        {
            var result = await _service.GetDetailAsync(id);

            if (result == null)
                return NotFound(ApiResponse<string>.Fail("Không tìm thấy cửa hàng"));

            return Ok(ApiResponse<StoreDto>.Ok(result));
        }
    }
}