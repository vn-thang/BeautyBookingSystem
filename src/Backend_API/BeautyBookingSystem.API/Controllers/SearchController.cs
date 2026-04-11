using BeautyBookingSystem.Application.DTOs.Search;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers
{
    [ApiController]
    [Route("api/search")]
    public class SearchController : ControllerBase
    {
        private readonly ISearchService _searchService;

        public SearchController(ISearchService searchService)
        {
            _searchService = searchService;
        }

        [HttpGet]
        public async Task<IActionResult> Search(
            [FromQuery] string? keyword,
            [FromQuery] string? location,
            [FromQuery] double? userLat,
            [FromQuery] double? userLng,
            [FromQuery] string sortBy = "nearest",
            [FromQuery] int? minRating = null,
            [FromQuery] decimal? minPrice = null,
            [FromQuery] decimal? maxPrice = null)
        {
            var request = new SearchRequest
            {
                Keyword = keyword,
                Location = location,
                UserLat = userLat,
                UserLng = userLng,
                SortBy = sortBy,
                MinRating = minRating,
                MinPrice = minPrice,
                MaxPrice = maxPrice
            };

            var result = await _searchService.SearchAsync(request);
            return Ok(result);
        }
    }
}