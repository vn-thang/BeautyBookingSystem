using BeautyBookingSystem.Application.DTOs.SystemConfig;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface ISystemConfigService
    {
        Task<List<SystemConfigDto>> GetAllConfigsAsync();
        Task<SystemConfigDto?> GetConfigByKeyAsync(string key);
        Task<bool> UpdateConfigAsync(string key, UpdateSystemConfigRequest request);
        Task<Dictionary<string, List<SystemConfigDto>>> GetAllConfigsGroupedAsync();
        Task<T?> GetValueAsync<T>(string key);
    }
}