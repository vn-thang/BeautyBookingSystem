using AutoMapper;
using BeautyBookingSystem.Application.DTOs.AdminReview;
using BeautyBookingSystem.Application.DTOs.AdminStore;
using BeautyBookingSystem.Application.DTOs.AdminUser;
using BeautyBookingSystem.Application.DTOs.Auth;
using BeautyBookingSystem.Application.DTOs.Category;
using BeautyBookingSystem.Application.DTOs.Notification;
using BeautyBookingSystem.Application.DTOs.Service;
using BeautyBookingSystem.Application.DTOs.ServiceGroup;
using BeautyBookingSystem.Application.DTOs.Staff;
using BeautyBookingSystem.Application.DTOs.Store;
using BeautyBookingSystem.Application.DTOs.StoreBooking;
using BeautyBookingSystem.Application.DTOs.StorePayment;
using BeautyBookingSystem.Application.DTOs.StoreReview;
using BeautyBookingSystem.Application.DTOs.StoreVoucher;
using BeautyBookingSystem.Application.DTOs.User;
using BeautyBookingSystem.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Mappers
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            CreateMap<RegisterRequest, User>();

            CreateMap<RegisterPartnerRequest, User>()
                .ForMember(dest => dest.FullName, opt => opt.MapFrom(src => src.OwnerName));

            CreateMap<RegisterPartnerRequest, Store>()
                .ForMember(dest => dest.Name, opt => opt.MapFrom(src => src.StoreName))
                .ForMember(dest => dest.Address, opt => opt.MapFrom(src => src.StoreAddress))
                .ForMember(dest => dest.Description, opt => opt.MapFrom(src => src.StoreDescription));

            CreateMap<User, UserProfileResponse>()
            .ForMember(dest => dest.Role, opt => opt.MapFrom(src => src.Role.ToString()))
            .ForMember(dest => dest.Status, opt => opt.MapFrom(src => src.Status.ToString()));

            CreateMap<UpdateProfileRequest, User>()
                .ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
           
            CreateMap<Store, StoreProfileDto>();
            CreateMap<StoreOperatingHour, OperatingHourDto>()
                .ForMember(dest => dest.OpenTime, opt => opt.MapFrom(src => src.OpenTime.ToString(@"hh\:mm")))
                .ForMember(dest => dest.CloseTime, opt => opt.MapFrom(src => src.CloseTime.ToString(@"hh\:mm")));

            CreateMap<StoreProfileDto, Store>()
                .ForMember(dest => dest.OperatingHours, opt => opt.Ignore());
            
            CreateMap<GlobalCategory, GlobalCategoryDto>();
            CreateMap<CreateCategoryRequest, GlobalCategory>();
            CreateMap<UpdateCategoryRequest, GlobalCategory>();
            
            CreateMap<Staff, StaffDtos>();
            CreateMap<CreateStaffRequest, Staff>();
            CreateMap<UpdateStaffRequest, Staff>();
            
            CreateMap<ServiceGroup, ServiceGroupDto>();
            CreateMap<CreateServiceGroupRequest, ServiceGroup>();
            CreateMap<UpdateServiceGroupRequest, ServiceGroup>();

            CreateMap<Service, ServiceDto>()
            .ForMember(dest => dest.CategoryName, opt => opt.MapFrom(src => src.Category != null ? src.Category.Name : "N/A"))
            .ForMember(dest => dest.GroupName, opt => opt.MapFrom(src => src.Group != null ? src.Group.Name : null));
            CreateMap<CreateServiceRequest, Service>();
            CreateMap<UpdateServiceRequest, Service>();

            CreateMap<Booking, StoreBookingListDto>()
            .ForMember(dest => dest.CustomerName, opt => opt.MapFrom(src => src.Customer.FullName))
            .ForMember(dest => dest.CustomerPhone, opt => opt.MapFrom(src => src.Customer.Phone));

            CreateMap<Booking, StoreBookingDetailDto>()
                .IncludeBase<Booking, StoreBookingListDto>()
                .ForMember(dest => dest.Services, opt => opt.MapFrom(src => src.BookingDetails));

            // Map từ BookingDetails -> BookingServiceItemDto
            CreateMap<BookingDetail, BookingServiceItemDto>()
                .ForMember(dest => dest.BookingDetailId, opt => opt.MapFrom(src => src.Id))
                .ForMember(dest => dest.ServiceName, opt => opt.MapFrom(src => src.Service.Name))
                .ForMember(dest => dest.StaffName, opt => opt.MapFrom(src => src.Staff != null ? src.Staff.FullName : string.Empty))
                .ForMember(dest => dest.DetailStatus, opt => opt.MapFrom(src => src.Status));

            // Map từ Staffs -> AvailableStaffDto
            CreateMap<Staff, AvailableStaffDto>();

            CreateMap<Payment, StorePaymentListDto>()
                .ForMember(dest => dest.CustomerName, opt => opt.MapFrom(src => src.Booking.Customer.FullName))
                .ForMember(dest => dest.PaymentMethod, opt => opt.MapFrom(src => src.PaymentMethod.ToString()))
                .ForMember(dest => dest.PaymentType, opt => opt.MapFrom(src => src.PaymentType.ToString()))
                .ForMember(dest => dest.Status, opt => opt.MapFrom(src => src.Status.ToString()));

            CreateMap<Review, StoreReviewDto>()
                .ForMember(dest => dest.CustomerName, opt => opt.MapFrom(src => src.Customer.FullName))
                .ForMember(dest => dest.CustomerAvatar, opt => opt.MapFrom(src => src.Customer.AvatarUrl));
           
            CreateMap<Voucher, VoucherDto>()
            .ForMember(dest => dest.ServiceName, opt => opt.MapFrom(src => src.Service != null ? src.Service.Name : null));

            CreateMap<Notification, NotificationDto>();

            CreateMap<User, UserDto>();
            CreateMap<User, UserDetailDto>()
                .IncludeBase<User, UserDto>()
                .ForMember(dest => dest.TotalBookings, opt => opt.MapFrom(src => src.Bookings.Count))
                .ForMember(dest => dest.TotalStores, opt => opt.MapFrom(src => src.Stores.Count))
                .ForMember(dest => dest.TotalReviews, opt => opt.MapFrom(src => src.Reviews.Count));

            CreateMap<Store, StoreAdminDto>()
            .ForMember(d => d.Status, opt => opt.MapFrom(s => s.ApprovalStatus)) 
            .ForMember(d => d.OwnerName, opt => opt.MapFrom(s => s.Owner.FullName));

            CreateMap<Store, StoreAdminDetailDto>()
                .ForMember(d => d.Status, opt => opt.MapFrom(s => s.ApprovalStatus))
                .ForMember(d => d.AvatarUrl, opt => opt.MapFrom(s => s.LogoUrl))
                .ForMember(d => d.OwnerName, opt => opt.MapFrom(s => s.Owner.FullName))
                .ForMember(d => d.OwnerEmail, opt => opt.MapFrom(s => s.Owner.Email));

            CreateMap<Review, ReviewDto>()
            .ForMember(dest => dest.CustomerName, opt => opt.MapFrom(src => src.Customer.FullName))
            .ForMember(dest => dest.StoreName, opt => opt.MapFrom(src => src.Store.Name));
        }
    }
}
