using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Customer")]
    public class VoucherController : ControllerBase
    {
        private readonly IVoucherService _voucherService;

        public VoucherController(IVoucherService voucherService)
        {
            _voucherService = voucherService;
        }

        [HttpGet("store/{storeId}")]
        public async Task<IActionResult> GetByStore(int storeId, [FromQuery] int? serviceId = null)
        {
            var result = await _voucherService.GetByStoreAsync(storeId, serviceId);
            return Ok(result);
        }

        [HttpGet("store/{storeId}/active")]
        public async Task<IActionResult> GetActiveByStore(int storeId, [FromQuery] int? serviceId = null)
        {
            var result = await _voucherService.GetActiveByStoreAsync(storeId, serviceId);
            return Ok(result);
        }

        [HttpGet("active")]
        public async Task<IActionResult> GetAllActive()
        {
            var result = await _voucherService.GetAllActiveAsync();
            return Ok(result);
        }

        [HttpGet("{code}")]
        public async Task<IActionResult> GetByCode(string code)
        {
            var result = await _voucherService.GetByCodeAsync(code);
            if (result == null) return NotFound();
            return Ok(result);
        }

        [HttpGet("service/{serviceId}/active")]
        public async Task<IActionResult> GetActiveByService(int serviceId, [FromQuery] int? storeId = null)
        {
            var result = await _voucherService.GetActiveByServiceAsync(serviceId, storeId);
            return Ok(result);
        }
        [HttpGet("service/home")]
        public async Task<IActionResult> GetServiceVouchersForHome([FromQuery] int? storeId = null)
        {
            var result = await _voucherService.GetActiveServiceVouchersAsync(storeId);
            return Ok(result);
        }
    }
}