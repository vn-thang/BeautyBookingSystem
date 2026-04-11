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
            var redirectUrl = await _walletService.ProcessVnPayCallbackAsync();
            
            return Redirect(redirectUrl);
        }
    }
}