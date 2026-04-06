using BeautyBookingSystem.Application.DTOs.SystemContent;
using BeautyBookingSystem.Domain.Enums;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface ISystemContentService
    {
        Task<List<SystemContentListDto>> GetAllForAdminAsync();
        Task<SystemContentDetailDto?> GetByIdForAdminAsync(int id);
        Task<bool> UpdateContentAsync(int id, UpdateSystemContentRequest request);
        Task<SystemContentDetailDto?> GetByTypeForPublicAsync(SystemContentType type);
        Task<bool> CreateContentAsync(CreateSystemContentRequest request);
    }
}