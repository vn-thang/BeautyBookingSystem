using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace BeautyBookingSystem.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ServicesController : ControllerBase
    {
        private readonly IServiceService _serviceService;

        public ServicesController(IServiceService serviceService)
        {
            _serviceService = serviceService;
        }

        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetById(int id)
        {
            var customerId = GetCurrentCustomerId();
            var service = await _serviceService.GetByIdAsync(id, customerId);

            if (service == null)
                return NotFound();

            return Ok(service);
        }

        [HttpGet("store/{storeId:int}")]
        public async Task<IActionResult> GetByStore(int storeId)
        {
            var result = await _serviceService.GetByStoreAsync(storeId);
            return Ok(result);
        }

        [HttpGet("category/{categoryId:int}")]
        public async Task<IActionResult> GetByCategory(int categoryId)
        {
            var result = await _serviceService.GetByCategoryAsync(categoryId);
            return Ok(result);
        }

        [HttpGet("group/{groupId:int}")]
        public async Task<IActionResult> GetByGroup(int groupId)
        {
            var result = await _serviceService.GetByGroupAsync(groupId);
            return Ok(result);
        }

        [HttpGet("featured")]
        public async Task<IActionResult> GetFeatured()
        {
            var result = await _serviceService.GetFeaturedAsync();
            return Ok(result);
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var result = await _serviceService.GetAllAsync();
            return Ok(result);
        }

        private int? GetCurrentCustomerId()
        {
            var claim = User.FindFirstValue(ClaimTypes.NameIdentifier);
            return int.TryParse(claim, out var customerId) ? customerId : null;
        }
    }
}