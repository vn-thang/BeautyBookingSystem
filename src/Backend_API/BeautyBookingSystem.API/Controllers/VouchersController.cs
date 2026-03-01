
using BeautyBookingSystem.Application.DTOs;
using BeautyBookingSystem.Application.DTOs.Common;
using BeautyBookingSystem.Application.Services;
using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/[controller]")]
public class VouchersController : ControllerBase
{
    private readonly VoucherService _service;

    public VouchersController(VoucherService service)
    {
        _service = service;
    }

    [HttpGet]
    public async Task<IActionResult> Get()
    {
        var result = await _service.GetActiveAsync();

        return Ok(ApiResponse<List<VoucherDto>>.Ok(result));
    }
}