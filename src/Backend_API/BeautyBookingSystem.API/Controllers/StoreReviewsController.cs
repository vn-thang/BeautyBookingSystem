using BeautyBookingSystem.Application.DTOs.StoreReview;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers
{
     [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "StoreOwner")]
    public class StoreReviewsController : ControllerBase
    {
        private readonly IStoreReviewService _storeReviewService;

        public StoreReviewsController(IStoreReviewService storeReviewService)
        {
            _storeReviewService = storeReviewService;
        }

        [HttpGet]
        public async Task<IActionResult> GetReviews([FromQuery] StoreReviewFilterRequest request)
        {
            var result = await _storeReviewService.GetReviewsAsync(request);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetReviewById(int id)
        {
            var result = await _storeReviewService.GetReviewByIdAsync(id);
            return Ok(result);
        }

        [HttpPut("{id}/reply")]
        public async Task<IActionResult> ReplyReview(int id, [FromBody] ReplyReviewRequest request)
        {
            var result = await _storeReviewService.ReplyReviewAsync(id, request);
            return Ok(new { message = "Trả lời đánh giá thành công!" });
        }
    }
}
