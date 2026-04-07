using AutoMapper;
using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.DTOs.StoreService;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Services
{
    public class StoreServiceService : IStoreServiceService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUserService _currentUserService; 
        private readonly IMapper _mapper;

        public StoreServiceService(IUnitOfWork unitOfWork, ICurrentUserService currentUserService, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _currentUserService = currentUserService;
            _mapper = mapper;
        }

        private async Task<Service> GetAndValidateOwnershipAsync(int id, int currentStoreId)
        {
            var service = await _unitOfWork.ServiceRepository.GetQueryable()
                .Include(s => s.Category)
                .Include(s => s.Group)
                .FirstOrDefaultAsync(s => s.Id == id);

            if (service == null || service.StoreId != currentStoreId)
                throw new NotFoundException("Không tìm thấy dịch vụ hoặc bạn không có quyền thao tác!");

            return service;
        }

        private async Task ValidateGroupOwnershipAsync(int? groupId, int currentStoreId)
        {
            if (groupId.HasValue && groupId.Value > 0)
            {
                var group = await _unitOfWork.ServiceGroupRepository.GetByIdAsync(groupId.Value);
                if (group == null || group.StoreId != currentStoreId)
                    throw new BadRequestException("Nhóm dịch vụ không hợp lệ hoặc không thuộc cửa hàng của bạn!");
            }
        }

        public async Task<List<ServiceDto>> GetAllByCurrentStoreAsync(bool onlyActive = true)
        {
            int currentStoreId = await _currentUserService.GetCurrentStoreIdAsync(); 

            var query = _unitOfWork.ServiceRepository.GetQueryable()
                .Include(s => s.Category)
                .Include(s => s.Group)
                .Where(s => s.StoreId == currentStoreId);

            if (onlyActive) query = query.Where(s => s.IsActive);

            var services = await query.OrderBy(s => s.SortOrder).ToListAsync();

            return _mapper.Map<List<ServiceDto>>(services);
        }

        public async Task<ServiceDto> GetByIdAsync(int id)
        {
            int currentStoreId = await _currentUserService.GetCurrentStoreIdAsync(); 
            var service = await GetAndValidateOwnershipAsync(id, currentStoreId);

            return _mapper.Map<ServiceDto>(service);
        }

        public async Task<ServiceDto> CreateAsync(CreateServiceRequest request)
        {
            int currentStoreId = await _currentUserService.GetCurrentStoreIdAsync(); 

            bool categoryExists = await _unitOfWork.GlobalCategoryRepository.GetQueryable()
                .AnyAsync(c => c.Id == request.CategoryId);
            if (!categoryExists) throw new NotFoundException("Danh mục hệ thống không tồn tại!");

            await ValidateGroupOwnershipAsync(request.GroupId, currentStoreId);

            var newService = _mapper.Map<Service>(request);
            newService.StoreId = currentStoreId;
            newService.IsActive = true;

            await _unitOfWork.ServiceRepository.AddAsync(newService);
            await _unitOfWork.SaveChangesAsync();

            return await GetByIdAsync(newService.Id);
        }

        public async Task<bool> UpdateAsync(int id, UpdateServiceRequest request)
        {
            int currentStoreId = await _currentUserService.GetCurrentStoreIdAsync(); 
            var service = await GetAndValidateOwnershipAsync(id, currentStoreId);

            if (request.GroupId != service.GroupId)
            {
                await ValidateGroupOwnershipAsync(request.GroupId, currentStoreId);
            }

            _mapper.Map(request, service);

            _unitOfWork.ServiceRepository.Update(service);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            int currentStoreId = await _currentUserService.GetCurrentStoreIdAsync(); 
            var service = await GetAndValidateOwnershipAsync(id, currentStoreId);
            service.IsActive = false;

            _unitOfWork.ServiceRepository.Update(service);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }
    }
}