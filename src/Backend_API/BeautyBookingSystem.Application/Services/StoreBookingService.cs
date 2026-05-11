using AutoMapper;
using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.DTOs.Booking;
using BeautyBookingSystem.Application.DTOs.StoreBooking;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
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
        private readonly IStoreWalletService _storeWalletService;
        private readonly IStoreVnPayService _vnPayService;

        public StoreBookingService(IUnitOfWork unitOfWork, IMapper mapper, ICurrentUserService currentUserService,IStoreVnPayService vnPayService, INotificationService notificationService, IStoreWalletService storeWalletService)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _currentUserService = currentUserService;
            _notificationService = notificationService;
            _storeWalletService = storeWalletService;
            _vnPayService = vnPayService;
        }

        public async Task<List<StoreBookingListDto>> GetBookingsAsync(string? status = null, int? staffId = null, DateTime? startDate = null, DateTime? endDate = null)
            {
                int storeId = await _currentUserService.GetCurrentStoreIdAsync();

                var query = _unitOfWork.BookingRepository.GetQueryable()
                    .Include(b => b.Customer)
                    .Where(b => b.StoreId == storeId);

                if (!string.IsNullOrEmpty(status) && Enum.TryParse<BookingStatus>(status, true, out var parsedStatus))
                {
                    query = query.Where(b => b.Status == parsedStatus);
                }
            if (staffId.HasValue)
            {
                query = query.Where(b => b.BookingDetails.Any(bd => bd.StaffId == staffId.Value));
            }
                if (startDate.HasValue)
                {
                    query = query.Where(b => b.CreatedAt >= startDate.Value.Date);
                }
                if (endDate.HasValue)
                {
                    var nextDay = endDate.Value.Date.AddDays(1);
                    query = query.Where(b => b.CreatedAt < nextDay);
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

        public async Task<List<AvailableStaffDto>> GetAvailableStaffsAsync(
            DateTime date, 
            TimeSpan startTime, 
            TimeSpan endTime, 
            int? excludeBookingId = null) 
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();
            var appointmentDayOfWeek = date.DayOfWeek;
            var bookingStartDateTime = date.Date.Add(startTime);
            var bookingEndDateTime = date.Date.Add(endTime);

            // 1. Lấy danh sách ID thợ bận
            var busyStaffIds = await _unitOfWork.BookingDetailRepository.GetQueryable()
                .Where(bd => bd.Booking.StoreId == storeId
                        && bd.AppointmentDate.Date == date.Date
                        && bd.Status != BookingDetailStatus.Cancelled 
                        && bd.Status != BookingDetailStatus.Done       
                        && bd.StaffId != null
                        && bd.BookingId != excludeBookingId) 
                .Where(bd => bd.StartTime < endTime && bd.EndTime > startTime)
                .Select(bd => bd.StaffId!.Value)
                .Distinct()
                .ToListAsync();

            // 2. Lọc thợ rảnh theo lịch làm việc và nghỉ phép
            var availableStaffs = await _unitOfWork.StaffRepository.GetQueryable()
                .Include(s => s.Schedules)
                .Include(s => s.Leaves)
                .Where(s => s.StoreId == storeId && s.IsActive && !busyStaffIds.Contains(s.Id))
                .Where(s => s.Schedules.Any(sch => 
                    sch.DayOfWeek == appointmentDayOfWeek && 
                    sch.IsWorking && 
                    sch.StartTime <= startTime && 
                    sch.EndTime >= endTime))
                .Where(s => !s.Leaves.Any(l => 
                    l.FromDate < bookingEndDateTime && 
                    l.ToDate > bookingStartDateTime))
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

            if (request != null && request.Assignments != null && request.Assignments.Any())
            {
                foreach (var assignment in request.Assignments)
                {
                    var detail = booking.BookingDetails.FirstOrDefault(bd => bd.Id == assignment.BookingDetailId);
                    if (detail != null)
                    {
                        var availableStaffs = await GetAvailableStaffsAsync(detail.AppointmentDate, detail.StartTime, 
                        detail.EndTime, bookingId);
                        
                        if (!availableStaffs.Any(s => s.Id == assignment.StaffId))
                        {
                            throw new BadRequestException($"Không thể phân công! Nhân viên (ID: {assignment.StaffId}) hiện không có ca làm việc, đang xin nghỉ phép, hoặc đã bị kẹt lịch khác trong khung giờ {detail.StartTime} - {detail.EndTime}.");
                        }

                        detail.StaffId = assignment.StaffId;
                    }
                }
            }

            var hasUnassignedStaff = booking.BookingDetails.Any(bd => bd.StaffId == null);
            if (hasUnassignedStaff)
            {
                throw new BadRequestException("Vui lòng phân công thợ cho tất cả các dịch vụ trước khi xác nhận đơn!");
            }
            booking.Status = BookingStatus.Confirmed;

            _unitOfWork.BookingRepository.Update(booking);
            var result = await _unitOfWork.SaveChangesAsync() > 0;

            if (result &&  booking.CustomerId.HasValue)
            {
                _ = _notificationService.CreateAndSendNotificationAsync(
                    booking.CustomerId.Value,
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
        int currentUserId = _currentUserService.GetUserId(); 

        var booking = await _unitOfWork.BookingRepository.GetQueryable()
            .Include(b => b.BookingDetails)
            .Include(b => b.Payments)
            .FirstOrDefaultAsync(b => b.Id == bookingId && b.StoreId == storeId);

        if (booking == null)
            throw new NotFoundException("Không tìm thấy đơn đặt lịch!");

        if (!Enum.TryParse<BookingStatus>(request.Status, true, out var newStatus))
        {
            throw new BadRequestException("Trạng thái không hợp lệ!"); 
        }

        booking.Status = newStatus;
        
        string customerNotificationTitle = string.Empty;
        string customerNotificationMessage = string.Empty;

        switch (newStatus)
        {
            case BookingStatus.Cancelled:

    booking.CancelledBy = CancelledByType.Store;
    booking.CancelReason = request.CancelReason;

    foreach (var detail in booking.BookingDetails)
    {
        detail.Status = BookingDetailStatus.Cancelled;
    }

    bool isRefunded = false;

    var vnPayDeposit = booking.Payments.FirstOrDefault(p =>
        p.PaymentMethod == PaymentMethod.VNPAY &&
        p.Status == PaymentStatus.Success);

    if (vnPayDeposit != null)
    {
        // ===== FAKE REFUND SANDBOX =====

        vnPayDeposit.Status = PaymentStatus.Refunded;

        _unitOfWork.PaymentRepository.Update(vnPayDeposit);

        var store = await _unitOfWork.StoreRepository
            .GetByIdAsync(booking.StoreId);

        if (store != null)
        {
            decimal balanceBefore = store.WalletBalance;

            store.WalletBalance -= vnPayDeposit.Amount;

            _unitOfWork.StoreRepository.Update(store);

            await _unitOfWork.WalletTransactionRepository.AddAsync(
                new WalletTransaction
                {
                    StoreId = store.Id,
                    BookingId = booking.Id,
                    Type = TransactionType.ClawbackDeposit,
                    Amount = vnPayDeposit.Amount,
                    BalanceBefore = balanceBefore,
                    BalanceAfter = store.WalletBalance,
                    Status = TransactionStatus.Completed,
                    Description = $"Hoàn tiền booking #{booking.Id}",
                    CreatedAt = DateTime.UtcNow
                }
            );
        }

        isRefunded = true;
    }

    if (isRefunded)
    {
        customerNotificationTitle =
            "Lịch hẹn đã hủy & Hoàn tiền";

        customerNotificationMessage =
            $"Cửa hàng đã hủy lịch hẹn #{booking.Id}. " +
            $"Số tiền {vnPayDeposit?.Amount:N0}đ đã được hoàn về ví/thẻ của bạn trong vài giờ tới.";
    }
    else
    {
        customerNotificationTitle = "Lịch hẹn đã bị hủy";

        customerNotificationMessage =
            $"Rất tiếc, lịch hẹn #{booking.Id} đã bị hủy bởi cửa hàng. " +
            $"Lý do: {request.CancelReason}";
    }

    break;

            case BookingStatus.Completed:
                foreach (var detail in booking.BookingDetails)
                {
                    detail.Status = BookingDetailStatus.Done;
                }

                var successfulPayments = booking.Payments.Where(p => p.Status == PaymentStatus.Success).ToList();
                var totalPaidAmount = successfulPayments.Sum(p => p.Amount);

                bool isFullyPaid = totalPaidAmount >= booking.FinalPrice;

                if (!isFullyPaid)
                {
                    var pendingPayment = booking.Payments.FirstOrDefault(p => p.Status == PaymentStatus.Pending);
                    
                    if (pendingPayment != null)
                    {
                        pendingPayment.Status = PaymentStatus.Success;
                        pendingPayment.PaidAt = DateTime.UtcNow;
                        pendingPayment.TransactionId = $"STORE_RECV_{DateTime.UtcNow.Ticks}"; 
                    }
                    else
                    {
                        decimal remainingAmount = booking.FinalPrice - totalPaidAmount;
                        
                        if (remainingAmount > 0)
                        {
                            var remainingPayment = new Payment
                            {
                                BookingId = booking.Id, 
                                PaymentMethod = PaymentMethod.COD, 
                                PaymentType = booking.DepositAmount > 0 ? PaymentType.Remaining : PaymentType.Full, 
                                Amount = remainingAmount,
                                Status = PaymentStatus.Success, 
                                PaidAt = DateTime.UtcNow,
                                TransactionId = $"STORE_RECV_{DateTime.UtcNow.Ticks}"
                            };

                            await _unitOfWork.PaymentRepository.AddAsync(remainingPayment);
                        }
                    }
                }

                customerNotificationTitle = "Dịch vụ hoàn tất";
                customerNotificationMessage = $"Đơn hàng #{booking.Id} đã hoàn thành. Cảm ơn bạn đã sử dụng dịch vụ tại cửa hàng! Hãy đánh giá trải nghiệm dịch vụ của bạn ngay nào.";
                break;
        }
        _unitOfWork.BookingRepository.Update(booking);
        await _unitOfWork.SaveChangesAsync();
        if (booking.CustomerId.HasValue) 
    {
        if (!string.IsNullOrEmpty(customerNotificationTitle))
        {
            await _notificationService.CreateAndSendNotificationAsync(
                booking.CustomerId.Value,
                customerNotificationTitle,
                customerNotificationMessage,
                NotificationType.BookingUpdate
            );
        }

        if (newStatus == BookingStatus.Completed)
    {
        decimal feeAmount = await _storeWalletService.ProcessBookingCommissionAsync(booking.Id);

        if (feeAmount > 0)
        {
            var storeEntity = await _unitOfWork.StoreRepository.GetByIdAsync(storeId);
            
            if (storeEntity != null)
            {
                await _notificationService.CreateAndSendNotificationAsync(
                    storeEntity.OwnerId, 
                    "💸 Trừ phí hoa hồng",
                    $"Hệ thống đã tự động trừ {feeAmount:N0}đ phí hoa hồng từ ví của bạn cho đơn hàng hoàn thành #{booking.Id}.",
                    NotificationType.BookingUpdate
                );
            }
        }
    }
    }
        return true; 
        }

        public async Task<BookingResponseDto> CreateStoreBookingAsync(CreateStoreBookingRequest request)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();
            var nowVN = DateTime.UtcNow.AddHours(7);

            var store = await _unitOfWork.StoreRepository.GetByIdAsync(storeId);
            if (store == null || !store.IsOpen)
                throw new InvalidOperationException("Cửa hàng hiện đang đóng cửa hoặc ngừng hoạt động, không thể tạo đơn.");

            if (request.Services == null || !request.Services.Any())
                throw new InvalidOperationException("Danh sách dịch vụ không được rỗng.");

            if (request.AppointmentDate.Date < nowVN.Date)
                throw new InvalidOperationException("Không thể tạo đơn cho ngày trong quá khứ.");

            var serviceItems = request.Services.ToList();
            var firstItem = serviceItems.First();

            var operatingHour = await _unitOfWork.StoreOperatingHourRepository.GetQueryable()
                .FirstOrDefaultAsync(w => w.StoreId == storeId && w.DayOfWeek == request.AppointmentDate.DayOfWeek);

            if (operatingHour == null)
                throw new InvalidOperationException("Cửa hàng không có lịch làm việc vào ngày này.");

            if (firstItem.StartTime < operatingHour.OpenTime)
                throw new InvalidOperationException($"Giờ hẹn ({firstItem.StartTime}) sớm hơn giờ mở cửa ({operatingHour.OpenTime}).");

            var loadedServices = new List<Service>();
            foreach (var item in serviceItems)
            {
                var service = await _unitOfWork.ServiceRepository.GetByIdAsync(item.ServiceId);
                if (service == null || service.StoreId != storeId)
                    throw new KeyNotFoundException($"Dịch vụ {item.ServiceId} không hợp lệ.");

                loadedServices.Add(service);
            }

            var booking = new Booking
            {
                StoreId = storeId,
                CustomerId = null,
                WalkInCustomerName = request.CustomerName,
                WalkInCustomerPhone = request.CustomerPhone,
                Source = BookingSource.StoreAdmin,
                CustomerNote = request.Note,
                Status = BookingStatus.Confirmed,
                DiscountAmount = 0,
                DepositAmount = 0,
            };

            decimal totalPrice = 0;
            var detailDtos = new List<BookingDetailResponseDto>();
            var currentStartTime = firstItem.StartTime;

            for (int i = 0; i < serviceItems.Count; i++)
            {
                var item = serviceItems[i];
                var service = loadedServices[i];

                var startTime = currentStartTime;
                var endTime = startTime.Add(TimeSpan.FromMinutes(service.DurationMinutes));

                if (endTime > operatingHour.CloseTime)
                    throw new InvalidOperationException($"Dịch vụ kết thúc lúc {endTime}, vượt quá giờ đóng cửa ({operatingHour.CloseTime}).");

                if (item.StaffId.HasValue && item.StaffId.Value > 0)
                {
                    var availableStaffs = await GetAvailableStaffsAsync(request.AppointmentDate, startTime, endTime);
                    if (!availableStaffs.Any(s => s.Id == item.StaffId.Value))
                        throw new InvalidOperationException($"Nhân viên ID {item.StaffId} đang bận hoặc nghỉ trong khung giờ {startTime} - {endTime}.");
                }

                var detail = new BookingDetail
                {
                    Booking = booking,
                    ServiceId = item.ServiceId,
                    StaffId = (item.StaffId.HasValue && item.StaffId.Value > 0) ? item.StaffId : null,
                    AppointmentDate = request.AppointmentDate.Date,
                    StartTime = startTime,
                    EndTime = endTime,
                    Price = service.Price,
                    Status = BookingDetailStatus.Pending
                };

                await _unitOfWork.BookingDetailRepository.AddAsync(detail);
                totalPrice += service.Price;

                detailDtos.Add(new BookingDetailResponseDto
                {
                    ServiceId = service.Id,
                    ServiceName = service.Name,
                    StaffId = detail.StaffId,
                    AppointmentDate = request.AppointmentDate.Date,
                    StartTime = startTime,
                    EndTime = endTime,
                    Price = service.Price
                });

                currentStartTime = endTime;
            }

            booking.TotalPrice = totalPrice;
            booking.FinalPrice = totalPrice;

            await _unitOfWork.BookingRepository.AddAsync(booking);

            var payment = new Payment
            {
                Booking = booking,
                PaymentMethod = PaymentMethod.COD,
                PaymentType = PaymentType.Full,
                Amount = totalPrice,
                Status = PaymentStatus.Pending
            };
            await _unitOfWork.PaymentRepository.AddAsync(payment);

            await _unitOfWork.SaveChangesAsync();

            return new BookingResponseDto
            {
                Id = booking.Id,
                TotalPrice = booking.TotalPrice,
                DiscountAmount = booking.DiscountAmount,
                DepositAmount = booking.DepositAmount,
                FinalPrice = booking.FinalPrice,
                Status = booking.Status,
                Services = detailDtos
            };
        }

    public async Task<List<TimeSlotDto>> GetAvailableTimeSlotsAsync(DateTime date, int totalDurationMinutes)
{
    int storeId = await _currentUserService.GetCurrentStoreIdAsync();
    var slots = new List<TimeSlotDto>();

    var store = await _unitOfWork.StoreRepository.GetByIdAsync(storeId);
    if (store == null || !store.IsOpen)
        return slots;

    var operatingHour = await _unitOfWork.StoreOperatingHourRepository.GetQueryable()
        .FirstOrDefaultAsync(w => w.StoreId == storeId && w.DayOfWeek == date.DayOfWeek);

    if (operatingHour == null || operatingHour.OpenTime == operatingHour.CloseTime) 
        return slots; 

    TimeSpan currentTime = operatingHour.OpenTime; 
    TimeSpan closingTime = operatingHour.CloseTime;
    var nowVN = DateTime.UtcNow.AddHours(7);

    while (currentTime.Add(TimeSpan.FromMinutes(totalDurationMinutes)) <= closingTime)
    {
        var endTime = currentTime.Add(TimeSpan.FromMinutes(totalDurationMinutes));
        
        bool isPastSlot = (date.Date == nowVN.Date && currentTime <= nowVN.TimeOfDay);

        bool isAvailable = false;

        if (!isPastSlot)
        {
            var availableStaffs = await GetAvailableStaffsAsync(date, currentTime, endTime);
            isAvailable = availableStaffs.Any();
        }

        slots.Add(new TimeSlotDto
        {
            Time = currentTime.ToString(@"hh\:mm"),
            IsAvailable = isAvailable
        });

        currentTime = currentTime.Add(TimeSpan.FromMinutes(totalDurationMinutes));
    }

    return slots;
}
    }
}
