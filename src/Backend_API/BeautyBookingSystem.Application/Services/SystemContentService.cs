using AutoMapper;
using AutoMapper.QueryableExtensions;
using BeautyBookingSystem.Application.DTOs.SystemContent;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace BeautyBookingSystem.Application.Services
{
    public class SystemContentService : ISystemContentService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public SystemContentService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }
        public async Task<List<SystemContentListDto>> GetAllForAdminAsync()
        {
            return await _unitOfWork.SystemContentRepository.GetQueryable()
                .OrderBy(c => c.Id)
                .ProjectTo<SystemContentListDto>(_mapper.ConfigurationProvider)
                .ToListAsync();
        }
        public async Task<SystemContentDetailDto?> GetByIdForAdminAsync(int id)
        {
            return await _unitOfWork.SystemContentRepository.GetQueryable()
                .Where(c => c.Id == id)
                .ProjectTo<SystemContentDetailDto>(_mapper.ConfigurationProvider)
                .FirstOrDefaultAsync();
        }

        public async Task<bool> UpdateContentAsync(int id, UpdateSystemContentRequest request)
        {
            var content = await _unitOfWork.SystemContentRepository.GetQueryable()
                .FirstOrDefaultAsync(c => c.Id == id);

            if (content == null) return false;

            content.Title = request.Title;
            content.Content = request.Content;
            content.IsActive = request.IsActive;
            _unitOfWork.SystemContentRepository.Update(content);
            return await _unitOfWork.SaveChangesAsync() > 0;
        }
        public async Task<SystemContentDetailDto?> GetByTypeForPublicAsync(SystemContentType type)
        {
            return await _unitOfWork.SystemContentRepository.GetQueryable()
                .Where(c => c.Type == type && c.IsActive == true) 
                .ProjectTo<SystemContentDetailDto>(_mapper.ConfigurationProvider)
                .FirstOrDefaultAsync();
        }
            
        public async Task<bool> CreateContentAsync(CreateSystemContentRequest request)
        {
            var newContent = new Domain.Entities.SystemContent
            {
                Type = (SystemContentType)request.Type,
                Title = request.Title,
                Content = request.Content,
                IsActive = request.IsActive
            };

            await _unitOfWork.SystemContentRepository.AddAsync(newContent);
            return await _unitOfWork.SaveChangesAsync() > 0;
        }
    }
}