using AutoMapper;
using AutoMapper.QueryableExtensions;
using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.DTOs.AdminBooking;
using BeautyBookingSystem.Application.DTOs.Common;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Services
{
    public class AdminBookingService : IAdminBookingService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly INotificationService _notificationService;

        public AdminBookingService(IUnitOfWork unitOfWork, IMapper mapper, INotificationService notificationService)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _notificationService = notificationService;
        }

        public async Task<PagedResponse<AdminBookingListDto>> GetBookingsAsync(AdminBookingFilterRequest request)
        {
            var query = _unitOfWork.BookingRepository.GetQueryable();
            if (!string.IsNullOrWhiteSpace(request.SearchTerm))
            {
                var search = request.SearchTerm.ToLower();
                query = query.Where(b => b.Id.ToString().Contains(search) || 
                                         b.Customer.FullName.ToLower().Contains(search) ||
                                         b.Customer.Phone.Contains(search));
            }

            if (request.StoreId.HasValue)
            {
                query = query.Where(b => b.StoreId == request.StoreId.Value);
            }

            if (request.Status.HasValue)
            {
                query = query.Where(b => b.Status == request.Status.Value);
            }
            if (request.PaymentStatus.HasValue)
            {
                query = query.Where(b => b.Payments.Any(p => p.Status == request.PaymentStatus.Value));
            }
            if (request.FromDate.HasValue)
            {
                query = query.Where(b => b.CreatedAt >= request.FromDate.Value);
            }
            if (request.ToDate.HasValue)
            {
                var toDate = request.ToDate.Value.Date.AddDays(1).AddTicks(-1); 
                query = query.Where(b => b.CreatedAt <= toDate);
            }

            int totalCount = await query.CountAsync();

            var bookings = await query
                .OrderByDescending(b => b.CreatedAt)
                .Skip((request.PageIndex - 1) * request.PageSize)
                .Take(request.PageSize)
                .ProjectTo<AdminBookingListDto>(_mapper.ConfigurationProvider)
                .ToListAsync();

           return PagedResponse<AdminBookingListDto>.Create(
                bookings, 
                totalCount, 
                request.PageIndex, 
                request.PageSize
            );
        }

        public async Task<AdminBookingDetailDto?> GetBookingByIdAsync(int id)
        {
            var booking = await _unitOfWork.BookingRepository.GetQueryable()
                .Where(b => b.Id == id)
                .ProjectTo<AdminBookingDetailDto>(_mapper.ConfigurationProvider)
                .FirstOrDefaultAsync();

            if (booking == null) throw new NotFoundException("Không tìm thấy đơn đặt lịch.");

            return booking;
        }

        public async Task<bool> CancelBookingAsync(int id, AdminCancelBookingRequest request)
        {
            var booking = await _unitOfWork.BookingRepository.GetQueryable()
                .Include(b => b.Customer)
                .Include(b => b.Store)
                .FirstOrDefaultAsync(b => b.Id == id);

            if (booking == null) throw new NotFoundException("Không tìm thấy đơn đặt lịch.");

            if (booking.Status == BookingStatus.Cancelled || booking.Status == BookingStatus.Completed)
                throw new BadRequestException("Không thể hủy đơn đặt lịch đã hoàn thành hoặc đã bị hủy trước đó.");

            booking.Status = BookingStatus.Cancelled;
            booking.CancelledBy = CancelledByType.Admin; 
            booking.CancelReason = $"[Hủy bởi Quản trị viên]: {request.Reason}";

            var details = await _unitOfWork.BookingDetailRepository.GetQueryable()
                .Where(d => d.BookingId == id).ToListAsync();
            foreach (var detail in details)
            {
                detail.Status = BookingDetailStatus.Cancelled;
                _unitOfWork.BookingDetailRepository.Update(detail);
            }

            _unitOfWork.BookingRepository.Update(booking);
            var result = await _unitOfWork.SaveChangesAsync() > 0;

            if (result)
            {
                _ = _notificationService.CreateAndSendNotificationAsync(
                    booking.CustomerId,
                    "⚠️ Đơn đặt lịch của bạn đã bị hủy",
                    $"Lịch hẹn tại {booking.Store.Name} đã bị hủy bởi Quản trị viên hệ thống. Lý do: {request.Reason}",
                    NotificationType.SystemAlert
                );

                _ = _notificationService.CreateAndSendNotificationAsync(
                    booking.Store.OwnerId,
                    "⚠️ Hệ thống vừa hủy một đơn đặt lịch của bạn",
                    $"Quản trị viên đã hủy lịch hẹn của khách hàng {booking.Customer.FullName}. Lý do: {request.Reason}",
                    NotificationType.SystemAlert
                );
            }

            return result;
        }
    }
}