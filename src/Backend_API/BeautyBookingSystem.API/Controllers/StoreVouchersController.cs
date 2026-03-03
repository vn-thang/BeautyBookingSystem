using BeautyBookingSystem.Application.DTOs.StoreVoucher;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers
{
    //[Route("api/[controller]")]
    [Route("api/store-vouchers")]
    [ApiController]
    [Authorize]
    public class StoreVouchersController : ControllerBase
    {
        private readonly IStoreVoucherService _storeVoucherService;

        public StoreVouchersController(IStoreVoucherService storeVoucherService)
        {
            _storeVoucherService = storeVoucherService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var result = await _storeVoucherService.GetAllVouchersAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _storeVoucherService.GetVoucherByIdAsync(id);
            return Ok(result);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateVoucherRequest request)
        {
            var result = await _storeVoucherService.CreateVoucherAsync(request);
            return Ok(result);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateVoucherRequest request)
        {
            await _storeVoucherService.UpdateVoucherAsync(id, request);
            return Ok(new { message = "Cập nhật khuyến mãi thành công!" });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            await _storeVoucherService.DeleteVoucherAsync(id);
            return Ok(new { message = "Xóa khuyến mãi thành công!" });
        }
    }
}
