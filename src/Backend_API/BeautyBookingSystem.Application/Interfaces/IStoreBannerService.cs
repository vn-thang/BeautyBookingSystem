using BeautyBookingSystem.Application.DTOs.StoreBanner;

namespace BeautyBookingSystem.Application.Interfaces
{
public interface IStoreBannerService
{
    Task<List<StoreBannerDto>> GetMyBannersAsync(); 
    Task<StoreBannerDto> AddBannerAsync(CreateStoreBannerDto dto);
    Task<bool> ToggleBannerStatusAsync(int id); 
    Task<bool> DeleteBannerAsync(int id);
}
}