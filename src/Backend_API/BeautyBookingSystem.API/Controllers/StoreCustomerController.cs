using BeautyBookingSystem.Application.DTOs.StoreCustomer;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Application.Common.Exceptions; // Nơi chứa các Exception tự tạo
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers
{
    [Route("api/store/{storeId}/customers")]
    [ApiController]
    [Authorize(Roles = "StoreOwner")] // Đảm bảo chỉ Chủ tiệm mới được vào đây
    public class StoreCustomerController : ControllerBase
    {
        private readonly IStoreCustomerService _storeCustomerService;

        public StoreCustomerController(IStoreCustomerService storeCustomerService)
        {
            _storeCustomerService = storeCustomerService;
        }

        /// <summary>
        /// Lấy danh sách khách hàng của cửa hàng
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetCustomers(int storeId, [FromQuery] string? searchTerm)
        {
            // Tùy chọn: Bạn có thể thêm code kiểm tra xem storeId này 
            // có đúng là của User đang đăng nhập (từ Token) hay không để tăng tính bảo mật.
            
            var customers = await _storeCustomerService.GetStoreCustomersAsync(storeId, searchTerm);
            
            return Ok(new 
            {
                Success = true,
                Message = "Lấy danh sách khách hàng thành công",
                Data = customers
            });
        }

        /// <summary>
        /// Lấy hồ sơ chi tiết của 1 khách hàng (Lịch sử làm đẹp, số lần hủy...)
        /// </summary>
    [HttpGet("{customerId:int}")]
        public async Task<IActionResult> GetCustomerProfile(int storeId, int customerId)
        {
            var profile = await _storeCustomerService.GetCustomerProfileAsync(storeId, customerId);

            if (profile == null)
            {
                // Sử dụng Exception hoặc trả về NotFound thẳng
                return NotFound(new { Success = false, Message = "Không tìm thấy khách hàng này trong hệ thống của tiệm." });
            }

            return Ok(new
            {
                Success = true,
                Message = "Lấy hồ sơ khách hàng thành công",
                Data = profile
            });
        }
    }
}