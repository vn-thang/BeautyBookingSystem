using BeautyBookingSystem.Application.DTOs.AdminStore;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers.Admin
{
    [Authorize(Roles = "Admin")]
    [ApiController]
    [Route("api/admin/stores")]
    public class AdminStoreController : ControllerBase
    {
        private readonly IAdminStoreService _adminStoreService;
        public AdminStoreController(IAdminStoreService adminStoreService)
        {
            _adminStoreService = adminStoreService;
        }

        [HttpGet]
        public async Task<IActionResult> GetStores([FromQuery] StoreFilterRequest request)
        {
            var result = await _adminStoreService.GetStoresAsync(request);
            return Ok(result);
        }

        [HttpGet("dropdown")]
        public async Task<IActionResult> GetStoresForDropdown()
        {
            var result = await _adminStoreService.GetStoresForDropdownAsync();
            return Ok(result); 
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetStoreById(int id)
        {
            var store = await _adminStoreService.GetStoreByIdAsync(id);
            if (store == null)
                return NotFound(new { message = "Không tìm thấy cửa hàng." }); 

            return Ok(store);
        }

        [HttpPut("{id}/approve")]
        public async Task<IActionResult> ApproveStore(int id, [FromBody] ApproveStoreRequest request)
        {
            var success = await _adminStoreService.ApproveStoreAsync(id, request);
            if (!success)
                return BadRequest(new { message = "Xử lý thất bại." });

            string msg = request.IsApproved ? "Đã phê duyệt cửa hàng thành công." : "Đã từ chối cửa hàng.";
            return Ok(new { message = msg });
        }

        [HttpPut("{id}/status")]
        public async Task<IActionResult> ChangeStatus(int id, [FromBody] UpdateStoreStatusRequest request)
        {
            var success = await _adminStoreService.ChangeStoreStatusAsync(id, request);
            if (!success)
                return BadRequest(new { message = "Cập nhật trạng thái thất bại." });

            return Ok(new { message = "Cập nhật trạng thái cửa hàng thành công." });
        }
        [HttpPut("{id}/fees")]
        public async Task<IActionResult> UpdateStoreFeeConfig(int id, [FromBody] UpdateStoreFeeConfigRequest request)
        {
            var success = await _adminStoreService.UpdateStoreFeeConfigAsync(id, request);
            if (!success)
                return BadRequest(new { message = "Cập nhật cấu hình phí thất bại." });

            return Ok(new { message = "Cập nhật cấu hình phí thành công." });
        }
    }
}
