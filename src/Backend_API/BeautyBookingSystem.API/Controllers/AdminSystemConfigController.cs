using BeautyBookingSystem.Application.DTOs.SystemConfig; // Đổi namespace
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers.Admin
{
    [Route("api/admin/system-configs")] 
    [ApiController]
    [Authorize(Roles = "Admin")]
    public class AdminSystemConfigController : ControllerBase
    {
        private readonly ISystemConfigService _systemConfigService; 
        public AdminSystemConfigController(ISystemConfigService systemConfigService)
        {
            _systemConfigService = systemConfigService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAllConfigs()
        {
            var configs = await _systemConfigService.GetAllConfigsAsync();
            return Ok(new { success = true, data = configs });
        }

        [HttpGet("grouped")]
        public async Task<IActionResult> GetAllConfigsGrouped()
        {
            var groupedConfigs = await _systemConfigService.GetAllConfigsGroupedAsync();
            return Ok(new { success = true, data = groupedConfigs });
        }

        [HttpGet("{key}")]
        public async Task<IActionResult> GetConfigByKey(string key)
        {
            var config = await _systemConfigService.GetConfigByKeyAsync(key);
            if (config == null)
            {
                return NotFound(new { success = false, message = "Không tìm thấy khóa cấu hình này." });
            }
            return Ok(new { success = true, data = config });
        }

        [HttpPut("{key}")]
        public async Task<IActionResult> UpdateConfig(string key, [FromBody] UpdateSystemConfigRequest request) 
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            try
            {
                var result = await _systemConfigService.UpdateConfigAsync(key, request);
                if (!result)
                {
                    return NotFound(new { success = false, message = "Không tìm thấy khóa cấu hình này." });
                }

                return Ok(new { success = true, message = "Cập nhật cấu hình thành công." });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }
    }
}