using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;

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
        var service = await _serviceService.GetByIdAsync(id);

        if (service == null)
            return NotFound();

        return Ok(service);
    }

    [HttpGet("store/{storeId}")]
    public async Task<IActionResult> GetByStore(int storeId)
    {
        var result = await _serviceService.GetByStoreAsync(storeId);
        return Ok(result);
    }

    [HttpGet("category/{categoryId}")]
    public async Task<IActionResult> GetByCategory(int categoryId)
    {
        var result = await _serviceService.GetByCategoryAsync(categoryId);
        return Ok(result);
    }

    [HttpGet("group/{groupId}")]
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

}