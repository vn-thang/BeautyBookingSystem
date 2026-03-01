using AutoMapper;
using BeautyBookingSystem.Application.DTOs;
using BeautyBookingSystem.Application.Interfaces;

namespace BeautyBookingSystem.Application.Services
{
    public class StoreService
    {
        private readonly IStoreRepository _repository;
        private readonly IMapper _mapper;

        public StoreService(
            IStoreRepository repository,
            IMapper mapper)
        {
            _repository = repository;
            _mapper = mapper;
        }

        public async Task<List<StoreDto>> GetApprovedAsync()
        {
            var stores = await _repository.GetApprovedAsync();
            return _mapper.Map<List<StoreDto>>(stores);
        }

        public async Task<StoreDto?> GetDetailAsync(int id)
        {
            var store = await _repository.GetDetailAsync(id);
            return store == null ? null : _mapper.Map<StoreDto>(store);
        }
    }
}