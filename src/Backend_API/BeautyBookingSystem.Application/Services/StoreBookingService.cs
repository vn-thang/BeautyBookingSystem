using AutoMapper;
using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.DTOs.StoreBooking;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Services
{
    public class StoreBookingService : IStoreBookingService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly ICurrentUserService _currentUserService;
        private readonly INotificationService _notificationService;

        public StoreBookingService(IUnitOfWork unitOfWork, IMapper mapper, ICurrentUserService currentUserService, INotificationService notificationService)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _currentUserService = currentUserService;
            _notificationService = notificationService;
        }

        public async Task<List<StoreBookingListDto>> GetBookingsAsync(string? status = null)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();

            var query = _unitOfWork.BookingRepository.GetQueryable()
                .Include(b => b.Customer)
                .Where(b => b.StoreId == storeId);

            if (!string.IsNullOrEmpty(status) && Enum.TryParse<BookingStatus>(status, true, out var parsedStatus))
            {
                query = query.Where(b => b.Status == parsedStatus);
            }

            var bookings = await query.OrderByDescending(b => b.CreatedAt).ToListAsync();
            return _mapper.Map<List<StoreBookingListDto>>(bookings);
        }

        public async Task<StoreBookingDetailDto> GetBookingDetailAsync(int bookingId)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();

            var booking = await _unitOfWork.BookingRepository.GetQueryable()
                .Include(b => b.Customer)
                .Include(b => b.BookingDetails).ThenInclude(bd => bd.Service)
                .Include(b => b.BookingDetails).ThenInclude(bd => bd.Staff)
                .Include(b => b.Payments)
                .FirstOrDefaultAsync(b => b.Id == bookingId && b.StoreId == storeId);

            if (booking == null)
                throw new NotFoundException("Không tìm thấy đơn đặt lịch hoặc đơn không thuộc cửa hàng này!");

            return _mapper.Map<StoreBookingDetailDto>(booking);
        }

        public async Task<List<AvailableStaffDto>> GetAvailableStaffsAsync(DateTime date, TimeSpan startTime, TimeSpan endTime)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();

            var busyStaffIds = await _unitOfWork.BookingDetailRepository.GetQueryable()
                .Where(bd => bd.Booking.StoreId == storeId
                          && bd.AppointmentDate.Date == date.Date
                          && bd.Status != BookingDetailStatus.Cancelled 
                          && bd.Status != BookingDetailStatus.Done      
                          && bd.StaffId != null)
                .Where(bd => bd.StartTime < endTime && bd.EndTime > startTime)
                .Select(bd => bd.StaffId!.Value)
                .Distinct()
                .ToListAsync();

            var availableStaffs = await _unitOfWork.StaffRepository.GetQueryable()
                .Where(s => s.StoreId == storeId && s.IsActive && !busyStaffIds.Contains(s.Id))
                .ToListAsync();

            return _mapper.Map<List<AvailableStaffDto>>(availableStaffs);
        }

        public async Task<bool> AssignStaffAndConfirmAsync(int bookingId, AssignStaffRequest request)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();

            var booking = await _unitOfWork.BookingRepository.GetQueryable()
                .Include(b => b.BookingDetails)
                .FirstOrDefaultAsync(b => b.Id == bookingId && b.StoreId == storeId);

            if (booking == null)
                throw new NotFoundException("Không tìm thấy đơn đặt lịch!");

            foreach (var assignment in request.Assignments)
            {
                var detail = booking.BookingDetails.FirstOrDefault(bd => bd.Id == assignment.BookingDetailId);
                if (detail != null)
                {
                    detail.StaffId = assignment.StaffId;
                }
            }

            booking.Status = BookingStatus.Confirmed;

            _unitOfWork.BookingRepository.Update(booking);
            var result = await _unitOfWork.SaveChangesAsync() > 0;

            if (result)
            {
                _ = _notificationService.CreateAndSendNotificationAsync(
                    booking.CustomerId,
                    "✅ Lịch hẹn đã được xác nhận",
                    $"Tuyệt vời! Lịch hẹn #{booking.Id} của bạn đã được cửa hàng xác nhận. Hẹn gặp bạn nhé!",
                    NotificationType.BookingUpdate
                );
            }

            return result;
        }

        public async Task<bool> UpdateStatusAsync(int bookingId, UpdateBookingStatusRequest request)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();

            var booking = await _unitOfWork.BookingRepository.GetQueryable()
                .Include(b => b.BookingDetails)
                .FirstOrDefaultAsync(b => b.Id == bookingId && b.StoreId == storeId);

            if (booking == null)
                throw new NotFoundException("Không tìm thấy đơn đặt lịch!");

            if (!Enum.TryParse<BookingStatus>(request.Status, true, out var newStatus))
            {
                throw new BadRequestException("Trạng thái không hợp lệ!"); 
            }

            booking.Status = newStatus;
            string notificationTitle = string.Empty;
            string notificationMessage = string.Empty;
            switch (newStatus)
            {
                case BookingStatus.Cancelled:
                    booking.CancelledBy = CancelledByType.Store;
                    booking.CancelReason = request.CancelReason;
                    foreach (var detail in booking.BookingDetails)
                        detail.Status = BookingDetailStatus.Cancelled;

                    notificationTitle = "Lịch hẹn đã bị hủy";
                    notificationMessage = $"Rất tiếc, lịch hẹn #{booking.Id} đã bị hủy bởi cửa hàng. Lý do: {request.CancelReason}";
                    break;

                case BookingStatus.Completed:
                    foreach (var detail in booking.BookingDetails)
                        detail.Status = BookingDetailStatus.Done;

                    notificationTitle = "Dịch vụ hoàn tất";
                    notificationMessage = $"Cảm ơn bạn đã sử dụng dịch vụ tại cửa hàng! Hy vọng bạn hài lòng với trải nghiệm vừa rồi.";
                    break;
            }

            _unitOfWork.BookingRepository.Update(booking);
            var result = await _unitOfWork.SaveChangesAsync() > 0;

            if (result && !string.IsNullOrEmpty(notificationTitle))
            {
                _ = _notificationService.CreateAndSendNotificationAsync(
                    booking.CustomerId,
                    notificationTitle,
                    notificationMessage,
                    NotificationType.BookingUpdate
                );
            }
            return result;
        }
    }
}
