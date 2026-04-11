// API/Controllers/ServiceGroupsController.cs
using Microsoft.AspNetCore.Mvc;
using BeautyBookingSystem.Application.Interfaces;

[Route("api/[controller]")]
[ApiController]
public class ServiceGroupsController : ControllerBase
{
    private readonly IServiceGroupService _service;

    public ServiceGroupsController(IServiceGroupService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        return Ok(await _service.GetAllAsync());
    }

    [HttpGet("store/{storeId}")]
    public async Task<IActionResult> GetByStore(int storeId)
    {
        return Ok(await _service.GetByStoreAsync(storeId));
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var result = await _service.GetByIdAsync(id);
        return result == null ? NotFound() : Ok(result);
    }
}