using BeautyBookingSystem.Application.DTOs.AdminReview;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers.Admin
{
    [Authorize(Roles = "Admin")]
    [ApiController]
    [Route("api/admin/reviews")]
    public class AdminReviewController : ControllerBase
    {
        private readonly IAdminReviewService _adminReviewService;

        public AdminReviewController(IAdminReviewService adminReviewService)
        {
            _adminReviewService = adminReviewService;
        }

        [HttpGet]
        public async Task<IActionResult> GetReviews([FromQuery] ReviewFilterRequest request)
        {
            var result = await _adminReviewService.GetReviewsAsync(request);
            return Ok(result);
        }

        [HttpPut("{id}/visibility")]
        public async Task<IActionResult> ToggleVisibility(int id, [FromBody] bool isHidden)
        {
            var success = await _adminReviewService.ToggleReviewVisibilityAsync(id, isHidden);

            if (!success)
                return BadRequest(new { message = "Cập nhật trạng thái đánh giá thất bại." });

            string msg = isHidden ? "Đã ẩn đánh giá thành công." : "Đã hiện đánh giá thành công.";
            return Ok(new { message = msg });
        }
    }
}
