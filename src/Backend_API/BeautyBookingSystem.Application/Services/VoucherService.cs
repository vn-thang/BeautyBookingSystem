using BeautyBookingSystem.Application.DTOs;
using BeautyBookingSystem.Application.Interfaces;
using AutoMapper;

public class VoucherService
{
    private readonly IUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;

    public VoucherService(IUnitOfWork unitOfWork, IMapper mapper)
    {
        _unitOfWork = unitOfWork;
        _mapper = mapper;
    }

    public async Task<List<VoucherDto>> GetActiveAsync()
    {
        var vouchers = await _unitOfWork.Vouchers.GetActiveAsync();

        return _mapper.Map<List<VoucherDto>>(vouchers);
    }
}