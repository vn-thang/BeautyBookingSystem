// API/Controllers/GlobalCategoriesController.cs
using Microsoft.AspNetCore.Mvc;
using BeautyBookingSystem.Application.Interfaces;

[Route("api/[controller]")]
[ApiController]
public class GlobalCategoriesController : ControllerBase
{
    private readonly IGlobalCategoryService _service;

    public GlobalCategoriesController(IGlobalCategoryService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        return Ok(await _service.GetAllAsync());
    }

    [HttpGet("active")]
    public async Task<IActionResult> GetActive()
    {
        return Ok(await _service.GetActiveAsync());
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var result = await _service.GetByIdAsync(id);
        return result == null ? NotFound() : Ok(result);
    }
}