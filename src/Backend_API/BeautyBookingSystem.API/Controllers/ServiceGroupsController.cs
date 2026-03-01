using BeautyBookingSystem.Application.DTOs;
using BeautyBookingSystem.Application.DTOs.Common;
using BeautyBookingSystem.Application.Services;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ServiceGroupsController : ControllerBase
    {
        private readonly ServiceGroupService _service;

        public ServiceGroupsController(ServiceGroupService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(ApiResponse<List<ServiceGroupDto>>.Ok(result));
        }

        [HttpGet("store/{storeId}")]
        public async Task<IActionResult> GetByStore(int storeId)
        {
            var result = await _service.GetByStoreAsync(storeId);
            return Ok(ApiResponse<List<ServiceGroupDto>>.Ok(result));
        }
    }
}