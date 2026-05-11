using BeautyBookingSystem.Application.DTOs.Payments;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using System;
using System.Threading.Tasks;

namespace BeautyBookingSystem.API.Controllers
{
    [ApiController]
    [Route("api/payments")]
    [Authorize(Roles = "Customer")]
    public class PaymentsController : ControllerBase
    {
        private readonly IConfiguration _config;
        private readonly ICustomerPaymentService _paymentService;

        public PaymentsController(IConfiguration config, ICustomerPaymentService paymentService)
        {
            _config = config;
            _paymentService = paymentService;
        }

        [HttpPost("vnpay/create")]
        public async Task<IActionResult> CreateVnpay([FromBody] CreatePaymentRequest req)
        {
            try
            {
                var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";
                var result = await _paymentService.CreatePaymentAsync(req, ipAddress);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet("vnpay/ipn")]
        [AllowAnonymous]
        public async Task<IActionResult> VnpayIpn()
        {
            var result = await _paymentService.ProcessVnpayCallbackAsync(Request.Query);

            return Ok(new
            {
                RspCode = result.Success ? "00" : "97",
                Message = result.Message
            });
        }

        [HttpGet("vnpay/return")]
        [AllowAnonymous]
        public async Task<IActionResult> VnPayReturn()
        {
            var result = await _paymentService.ProcessVnpayCallbackAsync(Request.Query);

            var appReturnUrl = _config["Vnpay:AppReturnUrl"]!;
            var status = result.Success ? "success" : "fail";

          return Content($@"
                    <!DOCTYPE html>
                    <html lang='vi'>
                    <head>
                        <meta charset='UTF-8'>
                        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
                        <title>Chuyển hướng ứng dụng</title>
                        <style>
                        body {{
                            text-align: center;
                            padding-top: 50px;
                            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
                            background-color: #f8f9fa;
                            color: #333;
                        }}
                        button {{
                            padding: 12px 24px;
                            font-size: 16px;
                            background-color: #007bff;
                            color: #ffffff;
                            border: none;
                            border-radius: 6px;
                            cursor: pointer;
                            font-weight: bold;
                            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                        }}
                        button:hover {{
                            background-color: #0056b3;
                        }}
                        </style>
                    </head>
                    <body>
                        <h2>Đang chuyển về ứng dụng...</h2>
                        <p>Vui lòng đợi trong giây lát.</p>
                        
                        <script>
                        setTimeout(function() {{
                            window.location.href = '{appReturnUrl}?status={status}';
                        }}, 500);
                        </script>
                        
                        <div style='margin-top: 30px;'>
                        <p style='font-size: 14px; color: #666;'>Nếu không tự chuyển, bấm nút bên dưới:</p>
                        <a href='{appReturnUrl}?status={status}' style='text-decoration: none;'>
                            <button>Quay về app</button>
                        </a>
                        </div>
                    </body>
                    </html>
                    ", "text/html; charset=utf-8"); 
        }
        [HttpPost("vnpay/refund/{paymentId}")]
public async Task<IActionResult> RefundVnpay(int paymentId, [FromQuery] int storeId)
{
    try
    {
        var result = await _paymentService.RefundPaymentAsync(paymentId, storeId, "Admin_API");
        
        if (result)
        {
            return Ok(new 
            { 
                Success = true,
                Message = "Hoàn tiền VNPay thành công. Số dư ví cửa hàng đã được cập nhật." 
            });
        }
        
        return BadRequest(new { Success = false, Message = "Xử lý hoàn tiền thất bại." });
    }
    catch (Exception ex)
    {
        return BadRequest(new { Success = false, Message = ex.Message });
    }
}
    }
}