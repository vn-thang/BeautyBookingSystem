using BeautyBookingSystem.Application.DTOs.Reviews;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BeautyBookingSystem.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Customer")]
    public class ReviewsController : ControllerBase
    {
        private readonly IReviewService _reviewService;

        public ReviewsController(IReviewService reviewService)
        {
            _reviewService = reviewService;
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateReviewRequestDto request)
        {
            var customerId = GetCurrentUserId();
            var result = await _reviewService.CreateAsync(customerId, request);
            return Ok(result);
        }

        [HttpGet("my-reviews")]
        public async Task<IActionResult> GetMyReviews()
        {
            var customerId = GetCurrentUserId();
            var result = await _reviewService.GetMyReviewsAsync(customerId);
            return Ok(result);
        }

        [HttpPut("{reviewId}/reply")]
        [Authorize(Roles = "Admin,Staff")]
        public async Task<IActionResult> Reply(int reviewId, [FromBody] string reply)
        {
            await _reviewService.ReplyAsync(reviewId, reply);
            return Ok(new { message = "Reply review thành công" });
        }

        private int GetCurrentUserId()
        {
            var claim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(claim))
                throw new UnauthorizedAccessException("Không tìm thấy user id trong token.");

            return int.Parse(claim);
        }

        [HttpGet("store/{storeId}/top")]
        [AllowAnonymous]
        public async Task<IActionResult> GetTopByStoreId(int storeId, [FromQuery] int take = 5)
        {
            var result = await _reviewService.GetTopByStoreIdAsync(storeId, take);
            return Ok(result);
        }

        [HttpGet("store/{storeId}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetByStoreId(int storeId, [FromQuery] int page = 1, [FromQuery] int pageSize = 10)
        {
            var items = await _reviewService.GetPagedByStoreIdAsync(storeId, page, pageSize);
            var total = await _reviewService.CountByStoreIdAsync(storeId);

            return Ok(new
            {
                page,
                pageSize,
                total,
                items
            });
        }
    }
}