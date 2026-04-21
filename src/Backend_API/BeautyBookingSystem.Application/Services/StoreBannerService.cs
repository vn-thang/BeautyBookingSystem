using BeautyBookingSystem.Application.DTOs.StoreBanner;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using Microsoft.EntityFrameworkCore;
namespace BeautyBookingSystem.Application.Services
{
public class StoreBannerService : IStoreBannerService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly ICurrentUserService _currentUserService;

    public StoreBannerService(IUnitOfWork unitOfWork, ICurrentUserService currentUserService)
    {
        _unitOfWork = unitOfWork;
        _currentUserService = currentUserService;
    }

    public async Task<List<StoreBannerDto>> GetMyBannersAsync()
    {
        int storeId = await _currentUserService.GetCurrentStoreIdAsync();
        
        return await _unitOfWork.StoreBannerRepository.GetQueryable()
            .Where(b => b.StoreId == storeId)
            .OrderBy(b => b.SortOrder)
            .Select(b => new StoreBannerDto
            {
                Id = b.Id,
                ImageUrl = b.ImageUrl,
                Title = b.Title,
                Description = b.Description,
                SortOrder = b.SortOrder,
                IsActive = b.IsActive
            })
            .ToListAsync();
    }

    public async Task<StoreBannerDto> AddBannerAsync(CreateStoreBannerDto dto)
    {
        int storeId = await _currentUserService.GetCurrentStoreIdAsync();

        var newBanner = new StoreBanner
        {
            StoreId = storeId,
            ImageUrl = dto.ImageUrl,
            Title = dto.Title,
            Description = dto.Description,
            SortOrder = dto.SortOrder,
            IsActive = true
        };

        await _unitOfWork.StoreBannerRepository.AddAsync(newBanner);
        await _unitOfWork.SaveChangesAsync();

        return new StoreBannerDto { Id = newBanner.Id, ImageUrl = newBanner.ImageUrl };
    }

    public async Task<bool> ToggleBannerStatusAsync(int id)
    {
        int storeId = await _currentUserService.GetCurrentStoreIdAsync();
        
        var banner = await _unitOfWork.StoreBannerRepository.GetByIdAsync(id);
        if (banner == null || banner.StoreId != storeId) 
            throw new Exception("Không tìm thấy banner hoặc không có quyền.");

        banner.IsActive = !banner.IsActive; 
        
        _unitOfWork.StoreBannerRepository.Update(banner);
        await _unitOfWork.SaveChangesAsync();
        return banner.IsActive;
    }

    public async Task<bool> DeleteBannerAsync(int id)
    {
        int storeId = await _currentUserService.GetCurrentStoreIdAsync();
        
        var banner = await _unitOfWork.StoreBannerRepository.GetByIdAsync(id);
        if (banner == null || banner.StoreId != storeId) 
            throw new Exception("Không tìm thấy banner hoặc không có quyền.");

        _unitOfWork.StoreBannerRepository.Delete(banner);
        await _unitOfWork.SaveChangesAsync();
        return true;
    }
    }
}