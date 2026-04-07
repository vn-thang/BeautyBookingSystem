using BeautyBookingSystem.Application.DTOs.SearchHistories;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BeautyBookingSystem.Api.Controllers
{
    [Authorize(Roles = "Customer")]
    [ApiController]
    [Route("api/search-histories")]
    public class SearchHistoriesController : ControllerBase
    {
        private readonly ISearchHistoryService _service;

        public SearchHistoriesController(ISearchHistoryService service)
        {
            _service = service;
        }

        [HttpGet("recent")]
        public async Task<IActionResult> GetRecent()
        {
            var customerId = GetCustomerId();
            var result = await _service.GetRecentAsync(customerId);
            return Ok(result);
        }

        [HttpPost]
        public async Task<IActionResult> Record([FromBody] CreateSearchHistoryRequest request)
        {
            var customerId = GetCustomerId();
            var result = await _service.RecordAsync(customerId, request.Keyword);
            return Ok(result);
        }

        [HttpDelete("{id:int}")]
        public async Task<IActionResult> Delete(int id)
        {
            var customerId = GetCustomerId();
            var result = await _service.DeleteAsync(customerId, id);
            return Ok(result);
        }

        private int GetCustomerId()
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrWhiteSpace(claim))
                throw new UnauthorizedAccessException("CustomerId not found in token.");

            return int.Parse(claim);
        }
    }
}