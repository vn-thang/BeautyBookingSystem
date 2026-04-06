using BeautyBookingSystem.Application.DTOs.SystemContent;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers.Admin
{
    [Route("api/admin/system-contents")]
    [ApiController]
    [Authorize(Roles = "Admin")]
    public class AdminSystemContentController : ControllerBase
    {
        private readonly ISystemContentService _contentService;

        public AdminSystemContentController(ISystemContentService contentService)
        {
            _contentService = contentService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var result = await _contentService.GetAllForAdminAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _contentService.GetByIdForAdminAsync(id);
            if (result == null) return NotFound("Không tìm thấy nội dung.");
            return Ok(result);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateSystemContentRequest request)
        {
            var success = await _contentService.UpdateContentAsync(id, request);
            if (!success) return BadRequest("Cập nhật thất bại hoặc không tìm thấy bài viết.");
            return Ok("Cập nhật thành công.");
        }
        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateSystemContentRequest request)
        {
            var success = await _contentService.CreateContentAsync(request);
            if (!success) return BadRequest("Không thể tạo nội dung mới.");
            return Ok("Tạo thành công.");
        }
    }
}