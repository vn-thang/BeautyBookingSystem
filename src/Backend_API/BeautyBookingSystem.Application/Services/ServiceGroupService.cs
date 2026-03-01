using AutoMapper;
using BeautyBookingSystem.Application.DTOs;
using BeautyBookingSystem.Application.Interfaces;

namespace BeautyBookingSystem.Application.Services
{
    public class ServiceGroupService
    {
        private readonly IServiceGroupRepository _repository;
        private readonly IMapper _mapper;

        public ServiceGroupService(
            IServiceGroupRepository repository,
            IMapper mapper)
        {
            _repository = repository;
            _mapper = mapper;
        }

        public async Task<List<ServiceGroupDto>> GetAllAsync()
        {
            var entities = await _repository.GetAllAsync();
            return _mapper.Map<List<ServiceGroupDto>>(entities);
        }

        public async Task<List<ServiceGroupDto>> GetByStoreAsync(int storeId)
        {
            var groups = await _repository.GetByStoreIdAsync(storeId);
            return _mapper.Map<List<ServiceGroupDto>>(groups);
        }
    }
}