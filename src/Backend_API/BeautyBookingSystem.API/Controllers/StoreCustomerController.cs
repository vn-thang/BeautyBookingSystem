using BeautyBookingSystem.Application.DTOs.StoreCustomer;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Application.Common.Exceptions; 
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers
{
    [Route("api/store/{storeId}/customers")]
    [ApiController]
    [Authorize(Roles = "StoreOwner")] 
    public class StoreCustomerController : ControllerBase
    {
        private readonly IStoreCustomerService _storeCustomerService;

        public StoreCustomerController(IStoreCustomerService storeCustomerService)
        {
            _storeCustomerService = storeCustomerService;
        }

        [HttpGet]
        public async Task<IActionResult> GetCustomers(int storeId, [FromQuery] string? searchTerm)
        {
            var customers = await _storeCustomerService.GetStoreCustomersAsync(storeId, searchTerm);
            
            return Ok(new 
            {
                Success = true,
                Message = "Lấy danh sách khách hàng thành công",
                Data = customers
            });
        }
    [HttpGet("{customerId:int}")]
        public async Task<IActionResult> GetCustomerProfile(int storeId, int customerId)
        {
            var profile = await _storeCustomerService.GetCustomerProfileAsync(storeId, customerId);

            if (profile == null)
            {
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