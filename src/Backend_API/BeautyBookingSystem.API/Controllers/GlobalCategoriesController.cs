using BeautyBookingSystem.Application.DTOs;
using BeautyBookingSystem.Application.DTOs.Common;
using BeautyBookingSystem.Application.Services;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class GlobalCategoriesController : ControllerBase
    {
        private readonly GlobalCategoryService _service;

        public GlobalCategoriesController(GlobalCategoryService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<IActionResult> Get()
        {
            var result = await _service.GetActiveAsync();
            return Ok(ApiResponse<List<GlobalCategoryDto>>.Ok(result));
        }
    }
}