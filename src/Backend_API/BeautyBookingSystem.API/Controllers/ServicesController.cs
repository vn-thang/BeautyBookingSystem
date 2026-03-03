using BeautyBookingSystem.Application.DTOs.Service;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "StoreOwner")]
    public class ServicesController : ControllerBase
    {
        private readonly IServiceService _serviceService;

        public ServicesController(IServiceService serviceService)
        {
            _serviceService = serviceService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll([FromQuery] bool onlyActive = true) 
        {
            var result = await _serviceService.GetAllByCurrentStoreAsync(onlyActive);
            return Ok(new { Message = "Lấy danh sách thành công", Data = result });
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _serviceService.GetByIdAsync(id);
            return Ok(new { Message = "Lấy thông tin thành công", Data = result });
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateServiceRequest request)
        {
            var result = await _serviceService.CreateAsync(request);
            return Ok(new { Message = "Tạo dịch vụ thành công", Data = result });
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateServiceRequest request)
        {
            await _serviceService.UpdateAsync(id, request);
            return Ok(new { Message = "Cập nhật dịch vụ thành công" });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            await _serviceService.DeleteAsync(id);
            return Ok(new { Message = "Đã ẩn dịch vụ thành công" });
        }
    }
}
