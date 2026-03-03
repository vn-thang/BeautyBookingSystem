using BeautyBookingSystem.Application.DTOs.Staff;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "StoreOwner")] 
    public class StaffsController : ControllerBase
    {
        private readonly IStaffService _staffService;

        public StaffsController(IStaffService staffService)
        {
            _staffService = staffService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var result = await _staffService.GetAllByCurrentStoreAsync(onlyActive: true);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _staffService.GetByIdAsync(id);
            return Ok(result);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateStaffRequest request)
        {
            var result = await _staffService.CreateAsync(request);
            return Ok(result);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateStaffRequest request)
        {
            await _staffService.UpdateAsync(id, request);
            return Ok(new { Message = "Cập nhật nhân viên thành công" });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            await _staffService.DeleteAsync(id);
            return Ok(new { Message = "Đã cho nhân viên nghỉ việc" });
        }
    }
}
