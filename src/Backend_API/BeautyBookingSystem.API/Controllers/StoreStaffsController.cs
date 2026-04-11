using BeautyBookingSystem.Application.DTOs.StoreStaff;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "StoreOwner")] 
    public class StoreStaffsController : ControllerBase
    {
        private readonly IStoreStaffService _staffService;

        public StoreStaffsController(IStoreStaffService staffService)
        {
            _staffService = staffService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll([FromQuery] bool onlyActive = true)
        {
            var result = await _staffService.GetAllByCurrentStoreAsync(onlyActive);

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
        [HttpGet("{id}/schedules")]
        public async Task<IActionResult> GetSchedules(int id)
        {
            var result = await _staffService.GetSchedulesAsync(id);
            return Ok(result);
        }

        [HttpPut("{id}/schedules")]
        public async Task<IActionResult> UpdateSchedules(int id, [FromBody] UpdateStaffScheduleWrapperRequest requestWrapper)
        {
            await _staffService.UpdateSchedulesAsync(id, requestWrapper.Schedules);
            return Ok(new { Message = "Cập nhật lịch làm việc thành công" });
        }
        [HttpGet("{id}/leaves")]
        public async Task<IActionResult> GetLeaves(int id)
        {
            var result = await _staffService.GetLeavesAsync(id);
            return Ok(result);
        }

        [HttpPost("{id}/leaves")]
        public async Task<IActionResult> CreateLeave(int id, [FromBody] CreateStaffLeaveRequest request)
        {
            await _staffService.CreateLeaveAsync(id, request);
            return Ok(new { Message = "Tạo đơn xin nghỉ thành công" });
        }

        [HttpDelete("{id}/leaves/{leaveId}")]
        public async Task<IActionResult> DeleteLeave(int id, int leaveId)
        {
            await _staffService.DeleteLeaveAsync(id, leaveId);
            return Ok(new { Message = "Hủy đơn xin nghỉ thành công" });
        }
    }
}
