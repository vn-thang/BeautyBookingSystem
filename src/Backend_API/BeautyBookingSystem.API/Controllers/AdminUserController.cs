using BeautyBookingSystem.Application.DTOs.AdminUser;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers
{
    [Authorize(Roles = "Admin")]
    [ApiController]
    [Route("api/admin/users")]
    public class AdminUserController : ControllerBase
    {
        private readonly IAdminUserService _adminUserService;

        public AdminUserController(IAdminUserService adminUserService)
        {
            _adminUserService = adminUserService;
        }

        [HttpGet]
        public async Task<IActionResult> GetUsers([FromQuery] UserFilterRequest request)
        {
            var result = await _adminUserService.GetUsersAsync(request);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetUserById(int id)
        {
            var user = await _adminUserService.GetUserByIdAsync(id);
            if (user == null) return NotFound(new { message = "Không tìm thấy người dùng này." });

            return Ok(user);
        }

        [HttpPut("{id}/status")]
        public async Task<IActionResult> ChangeStatus(int id, [FromBody] UpdateUserStatusRequest request)
        {
            var success = await _adminUserService.ChangeUserStatusAsync(id, request);
            if (!success) return BadRequest(new { message = "Cập nhật trạng thái thất bại hoặc không tìm thấy người dùng." });

            return Ok(new { message = "Cập nhật trạng thái thành công." });
        }
    }
}
