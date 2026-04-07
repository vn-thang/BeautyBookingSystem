using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Threading.Tasks;

namespace BeautyBookingSystem.API.Controllers
{
    [Route("api/store/bookings")]
    [ApiController]
    [Authorize(Roles = "StoreOwner")] 
    public class StoreBillingController : ControllerBase
    {
        private readonly IStoreBillingService _storeBillingService;
        public StoreBillingController(IStoreBillingService storeBillingService)
        {
            _storeBillingService = storeBillingService;
        }

        [HttpGet("{bookingId}/bill")]
        public async Task<IActionResult> GetBillDetail(int bookingId)
        {
            try
            {
                var billDetail = await _storeBillingService.GetBillDetailAsync(bookingId);
                return Ok(new 
                {
                    Success = true,
                    Message = "Lấy dữ liệu hóa đơn thành công",
                    Data = billDetail
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new 
                {
                    Success = false,
                    Message = ex.Message
                });
            }
        }
    }
}