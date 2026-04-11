// File: BeautyBookingSystem.Application.Services.SystemConfigService.cs
using AutoMapper;
using AutoMapper.QueryableExtensions;
using BeautyBookingSystem.Application.DTOs.SystemConfig;
using BeautyBookingSystem.Application.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace BeautyBookingSystem.Application.Services
{
    public class SystemConfigService : ISystemConfigService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public SystemConfigService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<List<SystemConfigDto>> GetAllConfigsAsync()
        {
            return await _unitOfWork.SystemConfigRepository.GetQueryable()
                .OrderBy(c => c.Group).ThenBy(c => c.Id)
                .ProjectTo<SystemConfigDto>(_mapper.ConfigurationProvider)
                .ToListAsync();
        }

        public async Task<Dictionary<string, List<SystemConfigDto>>> GetAllConfigsGroupedAsync()
        {
            var configs = await GetAllConfigsAsync();
            return configs
                .GroupBy(c => c.Group)
                .ToDictionary(g => g.Key, g => g.ToList());
        }

        public async Task<SystemConfigDto?> GetConfigByKeyAsync(string key)
        {
            return await _unitOfWork.SystemConfigRepository.GetQueryable()
                .Where(c => c.Key == key)
                .ProjectTo<SystemConfigDto>(_mapper.ConfigurationProvider)
                .FirstOrDefaultAsync();
        }

        public async Task<T?> GetValueAsync<T>(string key)
        {
            var config = await _unitOfWork.SystemConfigRepository.GetQueryable()
                .Where(c => c.Key == key)
                .FirstOrDefaultAsync();

            if (config == null || string.IsNullOrWhiteSpace(config.Value))
                return default;

            try
            {
                return (T)Convert.ChangeType(config.Value, typeof(T));
            }
            catch
            {
                return default;
            }
        }

        public async Task<bool> UpdateConfigAsync(string key, UpdateSystemConfigRequest request)
        {
            var config = await _unitOfWork.SystemConfigRepository.GetQueryable()
                .FirstOrDefaultAsync(c => c.Key == key);

            if (config == null) return false;

            switch (config.Type.ToLower())
            {
                case "number":
                  if (!decimal.TryParse(request.Value, System.Globalization.NumberStyles.Any, 
                  System.Globalization.CultureInfo.InvariantCulture, out var numericValue) || numericValue < 0)
                    {
                        throw new ArgumentException($"Giá trị của cấu hình '{config.Key}' phải là một số lớn hơn hoặc bằng 0.");
                    }
                    break;
                    
                case "boolean":
                    if (request.Value.ToLower() != "true" && request.Value.ToLower() != "false")
                    {
                        throw new ArgumentException($"Giá trị của cấu hình '{config.Key}' phải là 'true' hoặc 'false'.");
                    }
                    break;

                case "string":
                    break;
            }

            config.Value = request.Value;
            _unitOfWork.SystemConfigRepository.Update(config);
            
            return await _unitOfWork.SaveChangesAsync() > 0;
        }
    }
}