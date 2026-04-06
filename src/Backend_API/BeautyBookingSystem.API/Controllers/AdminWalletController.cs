using BeautyBookingSystem.Application.DTOs.AdminWallet;
using BeautyBookingSystem.Application.DTOs.StoreWallet;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers.Admin
{
    [Route("api/admin/wallets")]
    [ApiController]
    [Authorize(Roles = "Admin")] 
    public class AdminWalletController : ControllerBase
    {
        private readonly IAdminWalletService _adminWalletService;

        public AdminWalletController(IAdminWalletService adminWalletService)
        {
            _adminWalletService = adminWalletService;
        }

        [HttpGet("transactions")]
        public async Task<IActionResult> GetAllTransactions(
            [FromQuery] int pageIndex = 1, 
            [FromQuery] int pageSize = 10,
            [FromQuery] DateTime? startDate = null,
            [FromQuery] DateTime? endDate = null,
            [FromQuery] string? storeName = null,
            [FromQuery] TransactionType? type = null)
        {
            if (pageIndex <= 0) pageIndex = 1;
            if (pageSize <= 0 || pageSize > 100) pageSize = 10; 

            var result = await _adminWalletService.GetAllTransactionsAsync(
                pageIndex, pageSize, startDate, endDate, storeName, type);

            return Ok(new { success = true, data = result });
        }
        [HttpPost("stores/{storeId}/adjust")]
        public async Task<IActionResult> AdjustWalletBalance(int storeId, [FromBody] AdjustWalletRequest request)
        {
            var result = await _adminWalletService.AdjustStoreWalletBalanceAsync(storeId, request);
            if (result)
            {
                return Ok(new { success = true, message = "Điều chỉnh số dư ví thành công!" });
            }
            return BadRequest(new { success = false, message = "Điều chỉnh số dư thất bại." });
        }
        
        [HttpGet("withdrawals/pending")]
        public async Task<IActionResult> GetPendingWithdrawals(
            [FromQuery] int pageIndex = 1, 
            [FromQuery] int pageSize = 10,
            [FromQuery] string? storeName = null)
        {
            if (pageIndex <= 0) pageIndex = 1;
            if (pageSize <= 0 || pageSize > 100) pageSize = 10;

            var result = await _adminWalletService.GetPendingWithdrawalsAsync(pageIndex, pageSize, storeName);

            return Ok(new { success = true, data = result });
        }

        [HttpGet("withdrawals/history")]
        public async Task<IActionResult> GetProcessedWithdrawals(
            [FromQuery] int pageIndex = 1, 
            [FromQuery] int pageSize = 10,
            [FromQuery] string? storeName = null)
        {
            if (pageIndex <= 0) pageIndex = 1;
            if (pageSize <= 0 || pageSize > 100) pageSize = 10;

            var result = await _adminWalletService.GetProcessedWithdrawalsAsync(pageIndex, pageSize, storeName);

            return Ok(new { success = true, data = result });
        }

        [HttpPut("withdrawals/{id}/approve")]
        public async Task<IActionResult> ApproveWithdrawal(int id, [FromBody] ApproveWithdrawalDto request)
        {
            var result = await _adminWalletService.ApproveWithdrawalAsync(id, request);
            if (result)
            {
                return Ok(new { success = true, message = "Đã duyệt lệnh rút tiền thành công!" });
            }
            return BadRequest(new { success = false, message = "Xử lý duyệt lệnh thất bại." });
        }

        [HttpPut("withdrawals/{id}/reject")]
        public async Task<IActionResult> RejectWithdrawal(int id, [FromBody] RejectWithdrawalDto request)
        {
            var result = await _adminWalletService.RejectWithdrawalAsync(id, request);
            if (result)
            {
                return Ok(new { success = true, message = "Đã từ chối lệnh rút và hoàn tiền thành công!" });
            }
            return BadRequest(new { success = false, message = "Xử lý từ chối lệnh thất bại." });
        }
    }
}