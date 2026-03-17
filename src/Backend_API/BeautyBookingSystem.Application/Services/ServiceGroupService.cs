using AutoMapper;
using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.DTOs.Service;
using BeautyBookingSystem.Application.DTOs.ServiceGroup;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Services
{
    public class ServiceGroupService : IServiceGroupService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUserService _currentUserService;
        private readonly IMapper _mapper;

        public ServiceGroupService(IUnitOfWork unitOfWork, ICurrentUserService currentUserService, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _currentUserService = currentUserService; 
            _mapper = mapper;
        }

        private async Task<ServiceGroup> GetAndValidateOwnershipAsync(int id, int currentStoreId)
        {
            var group = await _unitOfWork.ServiceGroupRepository.GetByIdAsync(id);
            if (group == null || group.StoreId != currentStoreId)
                throw new NotFoundException("Nhóm dịch vụ không tồn tại hoặc bạn không có quyền thao tác!");

            return group;
        }

        public async Task<List<ServiceGroupDto>> GetAllByCurrentStoreAsync()
        {
            int currentStoreId = await _currentUserService.GetCurrentStoreIdAsync();

            var groups = await _unitOfWork.ServiceGroupRepository.GetQueryable()
                .Include(g => g.Services)
                .Where(g => g.StoreId == currentStoreId)
                .OrderBy(g => g.SortOrder)
                .ToListAsync();

            var result = _mapper.Map<List<ServiceGroupDto>>(groups);

            // 2. Lấy các dịch vụ "tự do" (GroupId == null) của cửa hàng hiện tại
            var ungroupedServices = await _unitOfWork.ServiceRepository.GetQueryable()
                .Where(s => s.StoreId == currentStoreId && s.GroupId == null)
                .OrderBy(s => s.SortOrder)
                .ToListAsync();

            // 3. Nếu có dịch vụ tự do -> Tạo nhóm ảo ID = 0 
            //if (ungroupedServices.Any())
            //{
            //    var virtualGroup = new ServiceGroupDto
            //    {
            //        Id = 0,
            //        Name = "Dịch vụ tự do",
            //        StoreId = currentStoreId,
            //        SortOrder = -1, 
            //        Services = _mapper.Map<List<ServiceDto>>(ungroupedServices) 
            //    };

            //    result.Insert(0, virtualGroup);
            // 3. Nếu có dịch vụ tự do -> Tạo nhóm ảo ID = 0 
            if (ungroupedServices.Any())
            {
                var mappedServices = _mapper.Map<List<ServiceDto>>(ungroupedServices);

                // 🔥 THÊM VÒNG LẶP NÀY ĐỂ GÁN GROUP ID = 0
                foreach (var s in mappedServices)
                {
                    s.GroupId = 0;
                }

                var virtualGroup = new ServiceGroupDto
                {
                    Id = 0,
                    Name = "Dịch vụ tự do",
                    StoreId = currentStoreId,
                    SortOrder = -1,
                    Services = mappedServices
                };

                result.Insert(0, virtualGroup);
            }
     
            return result;
        }

        public async Task<ServiceGroupDto> GetByIdAsync(int id)
        {
            int currentStoreId = await _currentUserService.GetCurrentStoreIdAsync();
            var group = await GetAndValidateOwnershipAsync(id, currentStoreId);

            return _mapper.Map<ServiceGroupDto>(group);
        }

        public async Task<ServiceGroupDto> CreateAsync(CreateServiceGroupRequest request)
        {
            int currentStoreId = await _currentUserService.GetCurrentStoreIdAsync();

            var newGroup = _mapper.Map<ServiceGroup>(request);
            newGroup.StoreId = currentStoreId;

            await _unitOfWork.ServiceGroupRepository.AddAsync(newGroup);
            await _unitOfWork.SaveChangesAsync();

            return _mapper.Map<ServiceGroupDto>(newGroup);
        }

        public async Task<bool> UpdateAsync(int id, UpdateServiceGroupRequest request)
        {
            int currentStoreId = await _currentUserService.GetCurrentStoreIdAsync();
            var group = await GetAndValidateOwnershipAsync(id, currentStoreId);

            _mapper.Map(request, group);

            _unitOfWork.ServiceGroupRepository.Update(group);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }

        public async Task<bool> DeleteAsync(int id)
        {
            int currentStoreId = await _currentUserService.GetCurrentStoreIdAsync();
            var group = await GetAndValidateOwnershipAsync(id, currentStoreId);

            bool hasServices = await _unitOfWork.ServiceRepository.GetQueryable()
                .AnyAsync(s => s.GroupId == id);

            if (hasServices)
                throw new BadRequestException("Không thể xóa vì nhóm này đang chứa dịch vụ.");

            _unitOfWork.ServiceGroupRepository.Delete(group);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }
    }
}