using BeautyBookingSystem.Application.DTOs.ServiceGroup;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace BeautyBookingSystem.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "StoreOwner")]
    public class ServiceGroupsController : ControllerBase
    {
        private readonly IServiceGroupService _serviceGroupService;

        public ServiceGroupsController(IServiceGroupService serviceGroupService)
        {
            _serviceGroupService = serviceGroupService;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var result = await _serviceGroupService.GetAllByCurrentStoreAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(int id)
        {
            var result = await _serviceGroupService.GetByIdAsync(id);
            return Ok(result);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] CreateServiceGroupRequest request)
        {
            var result = await _serviceGroupService.CreateAsync(request);
            return Ok(result);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateServiceGroupRequest request)
        {
            await _serviceGroupService.UpdateAsync(id, request);
            return Ok(new { Message = "Cập nhật nhóm dịch vụ thành công" });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(int id)
        {
            await _serviceGroupService.DeleteAsync(id);
            return Ok(new { Message = "Xóa nhóm dịch vụ thành công" });
        }
    }
}
