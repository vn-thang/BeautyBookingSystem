using BeautyBookingSystem.Application.DTOs.StorePayment;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class StorePaymentsController : ControllerBase
    {
        private readonly IStorePaymentService _paymentService;

        public StorePaymentsController(IStorePaymentService paymentService)
        {
            _paymentService = paymentService;
        }

        [HttpGet]
        public async Task<IActionResult> GetPayments([FromQuery] PaymentFilterRequest request)
        {
            var result = await _paymentService.GetPaymentsAsync(request);
            return Ok(result);
        }

        [HttpPut("{id}/confirm")]
        public async Task<IActionResult> ConfirmPayment(int id, [FromBody] ConfirmPaymentRequest request)
        {
            await _paymentService.ConfirmPaymentAsync(id, request);
            return Ok(new { message = "Xác nhận thanh toán thành công." });
        }

        [HttpPut("{id}/refund")]
        public async Task<IActionResult> RefundPayment(int id)
        {
            await _paymentService.RefundPaymentAsync(id);
            return Ok(new { message = "Đã cập nhật trạng thái hoàn tiền." });
        }
    }
}
