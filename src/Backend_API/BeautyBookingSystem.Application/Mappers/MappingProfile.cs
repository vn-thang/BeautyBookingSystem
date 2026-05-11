using AutoMapper;
using BeautyBookingSystem.Application.DTOs.AdminBooking;
using BeautyBookingSystem.Application.DTOs.SystemConfig;
using BeautyBookingSystem.Application.DTOs.AdminReview;
using BeautyBookingSystem.Application.DTOs.AdminStore;
using BeautyBookingSystem.Application.DTOs.AdminUser;
using BeautyBookingSystem.Application.DTOs.Auth;
using BeautyBookingSystem.Application.DTOs.Notification;
using BeautyBookingSystem.Application.DTOs.StoreBooking;
using BeautyBookingSystem.Application.DTOs.StorePayment;
using BeautyBookingSystem.Application.DTOs.StoreReview;
using BeautyBookingSystem.Application.DTOs.StoreVoucher;
using BeautyBookingSystem.Application.DTOs.StoreWallet;
using BeautyBookingSystem.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BeautyBookingSystem.Application.DTOs.AdminWallet;
using BeautyBookingSystem.Application.DTOs.SystemContent;
using BeautyBookingSystem.Application.DTOs.StoreUser;
using BeautyBookingSystem.Application.DTOs.AdminCategory;
using BeautyBookingSystem.Application.DTOs.MyStore;
using BeautyBookingSystem.Application.DTOs.StoreService;
using BeautyBookingSystem.Application.DTOs.StoreServiceGroup;
using BeautyBookingSystem.Application.DTOs.StoreStaff;
using BeautyBookingSystem.Domain.Enums;

namespace BeautyBookingSystem.Application.Mappers
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            CreateMap<RegisterRequest, User>();

            CreateMap<User, StoreUserProfileResponse>()
            .ForMember(dest => dest.Role, opt => opt.MapFrom(src => src.Role.ToString()))
            .ForMember(dest => dest.Status, opt => opt.MapFrom(src => src.Status.ToString()));

            CreateMap<StoreUpdateProfileRequest, User>()
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
            CreateMap<StaffSchedule, StaffScheduleDto>();
            CreateMap<StaffLeave, StaffLeaveDto>();
            
            CreateMap<ServiceGroup, ServiceGroupDto>();
            CreateMap<CreateServiceGroupRequest, ServiceGroup>();
            CreateMap<UpdateServiceGroupRequest, ServiceGroup>();

            CreateMap<Service, ServiceDto>()
            .ForMember(dest => dest.CategoryName, opt => opt.MapFrom(src => src.Category != null ? src.Category.Name : "N/A"))
            .ForMember(dest => dest.GroupName, opt => opt.MapFrom(src => src.Group != null ? src.Group.Name : null));
            CreateMap<CreateServiceRequest, Service>();
            CreateMap<UpdateServiceRequest, Service>();

            CreateMap<Booking, StoreBookingListDto>()
            .ForMember(dest => dest.CustomerName, opt => opt.MapFrom(src => 
        src.CustomerId.HasValue && src.Customer != null
            ? src.Customer.FullName 
            : src.WalkInCustomerName ?? "Khách vãng lai"))
            
    .ForMember(dest => dest.CustomerPhone, opt => opt.MapFrom(src => 
        src.CustomerId.HasValue && src.Customer != null
            ? src.Customer.Phone 
            : src.WalkInCustomerPhone ?? string.Empty))
             .ForMember(dest => dest.AvatarUrl, opt => opt.MapFrom(src =>
        src.CustomerId.HasValue && src.Customer != null
            ? src.Customer.AvatarUrl   
            : null                   
    ));

            CreateMap<Booking, StoreBookingDetailDto>()
                .IncludeBase<Booking, StoreBookingListDto>()
                .ForMember(dest => dest.Services, opt => opt.MapFrom(src => src.BookingDetails))
                .ForMember(dest => dest.PaymentId, opt => opt.MapFrom(src =>
                (src.Payments != null && src.Payments.Any())
                ? src.Payments.First().Id
                : (int?)null
                ))
                // .ForMember(dest => dest.RemainingAmount, opt => opt.MapFrom(src => src.FinalPrice - src.DepositAmount));

                .ForMember(dest => dest.RemainingAmount, opt => opt.MapFrom(src => 
                src.FinalPrice - (src.Payments != null 
                ? src.Payments.Where(p => p.Status == PaymentStatus.Success).Sum(p => p.Amount) 
                : 0)
    ));
                CreateMap<BookingDetail, BookingServiceItemDto>()
                .ForMember(dest => dest.BookingDetailId, opt => opt.MapFrom(src => src.Id))
                .ForMember(dest => dest.ServiceName, opt => opt.MapFrom(src => src.Service.Name))
                .ForMember(dest => dest.StaffName, opt => opt.MapFrom(src => src.Staff != null ? src.Staff.FullName : string.Empty))
                .ForMember(dest => dest.DetailStatus, opt => opt.MapFrom(src => src.Status));

            CreateMap<Staff, AvailableStaffDto>();

            CreateMap<Payment, StorePaymentListDto>()
                .ForMember(dest => dest.PaymentMethod, opt => opt.MapFrom(src => src.PaymentMethod.ToString()))
                .ForMember(dest => dest.PaymentType, opt => opt.MapFrom(src => src.PaymentType.ToString()))
                .ForMember(dest => dest.Status, opt => opt.MapFrom(src => src.Status.ToString()))
                .ForMember(dest => dest.BookingStatus, opt => opt.MapFrom(src => src.Booking.Status.ToString()))
                .ForMember(dest => dest.CustomerName, opt => opt.MapFrom(src => 
                src.Booking.CustomerId.HasValue 
                ? src.Booking.Customer.FullName 
                : src.Booking.WalkInCustomerName ?? "Khách vãng lai"))
            
                .ForMember(dest => dest.CustomerPhone, opt => opt.MapFrom(src => 
                src.Booking.CustomerId.HasValue 
                ? src.Booking.Customer.Phone 
                : src.Booking.WalkInCustomerPhone));

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

            CreateMap<Booking, AdminBookingListDto>()
            .ForMember(dest => dest.CustomerName, opt => opt.MapFrom(src => src.Customer.FullName))
            .ForMember(dest => dest.CustomerPhone, opt => opt.MapFrom(src => src.Customer.Phone))
            .ForMember(dest => dest.StoreName, opt => opt.MapFrom(src => src.Store.Name))
            .ForMember(dest => dest.PaymentStatus, opt => opt.MapFrom(src => 
        src.Payments.OrderByDescending(p => p.Id).Select(p => p.Status).FirstOrDefault()
    ));

            CreateMap<Booking, AdminBookingDetailDto>()
    .IncludeBase<Booking, AdminBookingListDto>()
    .ForMember(dest => dest.Services, opt => opt.MapFrom(src => src.BookingDetails))
    .ForMember(dest => dest.RemainingAmount, opt => opt.MapFrom(src => src.FinalPrice - src.DepositAmount));

            CreateMap<BookingDetail, AdminBookingDetailItemDto>()
    .ForMember(dest => dest.BookingDetailId, opt => opt.MapFrom(src => src.Id))
    .ForMember(dest => dest.ServiceName, opt => opt.MapFrom(src => src.Service.Name))
    .ForMember(dest => dest.StaffName, opt => opt.MapFrom(src => src.Staff != null ? src.Staff.FullName : null))
    .ForMember(dest => dest.Status, opt => opt.MapFrom(src => src.Status));

    CreateMap<WalletTransaction, WalletTransactionDto>();
    CreateMap<SystemConfig, SystemConfigDto>();
    CreateMap<WalletTransaction, AdminWalletTransactionDto>()
    .ForMember(dest => dest.StoreName, opt => opt.MapFrom(src => src.Store.Name));
    CreateMap<AdjustWalletRequest, WalletTransaction>()
    .ForMember(dest => dest.Description, opt => opt.MapFrom(src => src.Reason));
    CreateMap<SystemContent, SystemContentListDto>();
    CreateMap<SystemContent, SystemContentDetailDto>();
    CreateMap<WithdrawalRequest, WithdrawalRequestDto>()
        .ForMember(dest => dest.StoreName, opt => opt.MapFrom(src => src.Store.Name))
        .ForMember(dest => dest.Status, opt => opt.MapFrom(src => (int)src.Status));
        }
    }
}
