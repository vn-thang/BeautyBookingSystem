using AutoMapper;
using BeautyBookingSystem.Application.DTOs;
using BeautyBookingSystem.Application.Interfaces;

namespace BeautyBookingSystem.Application.Services
{
    public class GlobalCategoryService
    {
        private readonly IGlobalCategoryRepository _repository;
        private readonly IMapper _mapper;

        public GlobalCategoryService(
            IGlobalCategoryRepository repository,
            IMapper mapper)
        {
            _repository = repository;
            _mapper = mapper;
        }

        public async Task<List<GlobalCategoryDto>> GetActiveAsync()
        {
            var categories = await _repository.GetActiveAsync();
            return _mapper.Map<List<GlobalCategoryDto>>(categories);
        }
    }
}