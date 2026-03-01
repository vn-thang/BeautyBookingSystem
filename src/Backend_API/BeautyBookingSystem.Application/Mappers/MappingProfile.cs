using AutoMapper;
using BeautyBookingSystem.Application.DTOs;
using BeautyBookingSystem.Domain.Entities;
using static System.Runtime.InteropServices.JavaScript.JSType;

public class MappingProfile : Profile
{
    public MappingProfile()
    {
        CreateMap<Voucher, VoucherDto>()
            .ForMember(dest => dest.DiscountType,
                       opt => opt.MapFrom(src => src.DiscountType.ToString()));
        CreateMap<GlobalCategory, GlobalCategoryDto>();
        CreateMap<ServiceGroup, ServiceGroupDto>();
        CreateMap<Store, StoreDto>();
    }
}