using BeautyBookingSystem.Application.DTOs.StoreWallet;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace BeautyBookingSystem.API.Controllers
{
    [Route("api/store/wallet")]
    [ApiController]
    public class StoreWalletController : ControllerBase
    {
        private readonly IStoreWalletService _walletService;
        private readonly IWithdrawalService _withdrawalService;
        public StoreWalletController(IStoreWalletService walletService, IWithdrawalService withdrawalService)
        {
            _walletService = walletService;
            _withdrawalService = withdrawalService;
        }

        [HttpGet("balance")]
        [Authorize(Roles = "StoreOwner")]
        public async Task<IActionResult> GetMyWalletBalance()
        {
            var result = await _walletService.GetWalletBalanceAsync();
            return Ok(result);
        }

        [HttpGet("dashboard")]
        [Authorize(Roles = "StoreOwner")]
        public async Task<IActionResult> GetMyWalletDashboard([FromQuery] int? month = null, [FromQuery] int? year = null)
        {
            var result = await _walletService.GetWalletDashboardAsync(month, year);
            return Ok(result);
        }

        [HttpGet("history")]
        [Authorize(Roles = "StoreOwner")]
        public async Task<IActionResult> GetMyTransactionHistory(
            [FromQuery] int pageIndex = 1, 
            [FromQuery] int pageSize = 10,
            [FromQuery] int? month = null,
            [FromQuery] int? year = null,
            [FromQuery] TransactionType? type = null)
        {
            var result = await _walletService.GetTransactionHistoryAsync(pageIndex, pageSize, month, year, type);
            return Ok(result);
        }

        [HttpPost("create-topup-url")]
        [Authorize(Roles = "StoreOwner")]
        public async Task<IActionResult> CreateTopUpUrl([FromBody] TopUpRequest request)
        {
            var url = await _walletService.CreateVnPayTopUpUrlAsync(request);
            return Ok(new { success = true, paymentUrl = url });
        }

       [HttpPost("withdrawals")]
        [Authorize(Roles = "StoreOwner")]
        public async Task<IActionResult> CreateWithdrawalRequest([FromBody] CreateWithdrawalDto request)
        {
            await _withdrawalService.CreateRequestAsync(request);
            
            return Ok(new { Message = "Tạo yêu cầu rút tiền thành công." });
        }

        [HttpGet("withdrawals")]
        [Authorize(Roles = "StoreOwner")]
        public async Task<IActionResult> GetMyWithdrawalRequests()
        {
            var result = await _withdrawalService.GetStoreRequestsAsync();
            
            return Ok(result);
        }

       [HttpGet("vnpay-return")]
        [AllowAnonymous] 
        public async Task<IActionResult> PaymentCallback()
        {
            try
            {
                string appDeepLink = await _walletService.ProcessVnPayCallbackAsync();
                
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
                            // Tự động mở Deep Link
                            window.location.href = '{appDeepLink}';
                        }}, 1500); // Đợi 1.5 giây rồi chuyển hướng
                        </script>
                        
                        <div style='margin-top: 30px;'>
                        <p style='font-size: 14px; color: #666;'>Nếu không tự chuyển, bấm nút bên dưới:</p>
                        <a href='{appDeepLink}' style='text-decoration: none;'>
                            <button>Quay về app</button>
                        </a>
                        </div>
                    </body>
                    </html>
                    ", "text/html; charset=utf-8");
            }
            catch (Exception ex)
            {
                string errorDeepLink = "beautybooking://payment-result?success=false";
                
                return Content($@"
                    <!DOCTYPE html>
                    <html lang='vi'>
                    <head>
                        <meta charset='UTF-8'>
                        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
                        <title>Giao dịch thất bại</title>
                        <style>
                        body {{
                            text-align: center;
                            padding-top: 50px;
                            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
                            background-color: #f8f9fa;
                            color: #dc3545; /* Màu đỏ báo lỗi */
                        }}
                        button {{
                            padding: 12px 24px;
                            font-size: 16px;
                            background-color: #dc3545;
                            color: #ffffff;
                            border: none;
                            border-radius: 6px;
                            cursor: pointer;
                            font-weight: bold;
                        }}
                        </style>
                    </head>
                    <body>
                        <h2>Thanh toán thất bại!</h2>
                        <p>{ex.Message}</p>
                        <br/>
                        <a href='{errorDeepLink}' style='text-decoration: none;'>
                            <button>Quay về app</button>
                        </a>
                        
                        <script>
                        setTimeout(function() {{
                            window.location.href = '{errorDeepLink}';
                        }}, 2000);
                        </script>
                    </body>
                    </html>
                    ", "text/html; charset=utf-8");
            }
        }
    }
}