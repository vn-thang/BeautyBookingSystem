using BeautyBookingSystem.Application.DTOs.StoreBanner;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
namespace BeautyBookingSystem.API.Controllers
{
[ApiController]
 [Authorize(Roles = "StoreOwner")] 
public class StoreBannerController : ControllerBase
{
    private readonly IStoreBannerService _bannerService;

    public StoreBannerController(IStoreBannerService bannerService)
    {
        _bannerService = bannerService;
    }
   
    [Route("api/my-store/banners")]
    [HttpGet]
    public async Task<IActionResult> GetMyBanners()
    {
        var result = await _bannerService.GetMyBannersAsync();
        return Ok(result);
    }
    [Route("api/my-store/banners")]
    [HttpPost]
    public async Task<IActionResult> AddBanner([FromBody] CreateStoreBannerDto dto)
    {
        var result = await _bannerService.AddBannerAsync(dto);
        return Ok(result);
    }

    [Authorize]
    [Route("api/my-store/banners/{id}/toggle-status")]
    [HttpPut]
    public async Task<IActionResult> ToggleStatus(int id)
    {
        var isActive = await _bannerService.ToggleBannerStatusAsync(id);
        return Ok(new { Message = "Đổi trạng thái thành công", IsActive = isActive });
    }

    [Authorize]
    [Route("api/my-store/banners/{id}")]
    [HttpDelete]
    public async Task<IActionResult> DeleteBanner(int id)
    {
        await _bannerService.DeleteBannerAsync(id);
        return Ok(new { Message = "Đã xóa banner" });
    }
    }
}