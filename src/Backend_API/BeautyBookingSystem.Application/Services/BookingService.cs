using BeautyBookingSystem.Application.DTOs.Booking;
using BeautyBookingSystem.Application.DTOs.Staff;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Constants;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.EntityFrameworkCore;
using Hangfire;
using BeautyBookingSystem.Application.Common.Exceptions;

namespace BeautyBookingSystem.Application.Services
{
    public class BookingService : IBookingService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly INotificationService _notificationService;
        private readonly ISystemConfigService _systemConfigService;
        IStoreVnPayService _vnPayService ;
        IStoreWalletService _storeWalletService;

        public BookingService(IUnitOfWork unitOfWork, INotificationService notificationService, ISystemConfigService systemConfigService)
        {
            _unitOfWork = unitOfWork;
            _notificationService = notificationService;
            _systemConfigService = systemConfigService;
        }

        public async Task<BookingResponseDto> CreateBookingAsync(
            int customerId,
            CreateBookingRequest request)
        {
            bool blockUserIfNoShow = await _systemConfigService.GetValueAsync<bool>(SystemConfigKeys.BlockUserIfNoShow);
    
    if (blockUserIfNoShow)
    {
        int noShowLimit = await _systemConfigService.GetValueAsync<int>(SystemConfigKeys.NoShowLimit);
        if (noShowLimit <= 0) noShowLimit = 5;

        int currentNoShowCount = await CountCustomerNoShowsAsync(customerId);

        if (currentNoShowCount >= noShowLimit)
        {
            throw new UnauthorizedAccessException($"Tài khoản của bạn đã bị khóa tính năng đặt lịch do có {currentNoShowCount} lần không đến đúng hẹn. Vui lòng liên hệ cửa hàng để được hỗ trợ.");
        }
    } 
    int maxCancelPerDay = await _systemConfigService.GetValueAsync<int>(SystemConfigKeys.MaxCancelPerDay);
    
    if (maxCancelPerDay > 0)
    {
        var todayStart = DateTime.UtcNow.AddHours(7).Date; 
        var todayEnd = todayStart.AddDays(1);

        int todayCancelCount = await _unitOfWork.BookingRepository.GetQueryable()
            .Where(b => b.CustomerId == customerId 
                     && b.Status == BookingStatus.Cancelled 
                     && b.CancelledBy == CancelledByType.Customer) 
            .Where(b => b.UpdatedAt >= todayStart && b.UpdatedAt < todayEnd) 
            .CountAsync();

        if (todayCancelCount >= maxCancelPerDay)
        {
            throw new BadRequestException($"Bạn đã hủy {todayCancelCount} đơn trong hôm nay (vượt mức cho phép). Để tránh spam hệ thống, vui lòng thử đặt lại vào ngày mai.");
        }
    }

            if (request.Services == null || !request.Services.Any())
                throw new InvalidOperationException("Danh sách dịch vụ không được rỗng");

            if (request.DepositAmount < 0)
                throw new InvalidOperationException("Deposit amount không hợp lệ");

            var serviceItems = request.Services.ToList();
            var firstItem = serviceItems.First();

            int minHours = await _systemConfigService.GetValueAsync<int>(SystemConfigKeys.BookingMinHours);
            if (    minHours <= 0) minHours = 2;
            var bookingDateTime = firstItem.AppointmentDate.Date.Add(firstItem.StartTime);
            var nowVN = DateTime.UtcNow.AddHours(7); 

            if (bookingDateTime < nowVN.AddHours(minHours))
            {
                throw new InvalidOperationException($"Hệ thống yêu cầu đặt lịch trước tối thiểu {minHours} tiếng. Vui lòng chọn giờ muộn hơn.");
            }

            if (serviceItems.Any(x => x.AppointmentDate.Date != firstItem.AppointmentDate.Date))
                throw new InvalidOperationException("Tất cả dịch vụ phải cùng ngày hẹn");

            if (serviceItems.Any(x => x.StartTime != firstItem.StartTime))
                throw new InvalidOperationException("Tất cả dịch vụ phải cùng thời gian bắt đầu");

            var loadedServices = new List<Service>();
            foreach (var item in serviceItems)
            {
                var service = await _unitOfWork.ServiceRepository.GetByIdAsync(item.ServiceId);
                if (service == null)
                    throw new KeyNotFoundException("Service not found");

                loadedServices.Add(service);
            }

            var totalDurationMinutes = loadedServices.Sum(s => s.DurationMinutes);
            var bookingStartTime = firstItem.StartTime;
            var bookingEndTime = bookingStartTime.Add(TimeSpan.FromMinutes(totalDurationMinutes));

            var requestedStaffIds = serviceItems
                .Select(x => x.StaffId)
                .Where(x => x.HasValue)
                .Select(x => x.Value)
                .Distinct()
                .ToList();

            if (requestedStaffIds.Count > 1)
                throw new InvalidOperationException("Tất cả dịch vụ phải dùng cùng một nhân viên hoặc để trống để hệ thống tự chọn");

            int? requestedStaffId = requestedStaffIds.Count == 1 ? requestedStaffIds[0] : null;

            var assignedStaffId = await ResolveAssignedStaffIdAsync(
                request.StoreId,
                firstItem.AppointmentDate,
                bookingStartTime,
                bookingEndTime,
                requestedStaffId);

            var booking = new Booking
            {
                CustomerId = customerId,
                StoreId = request.StoreId,
                VoucherId = request.VoucherId,
                CustomerNote = request.CustomerNote,
                DepositAmount = request.DepositAmount,
                Status = BookingStatus.Pending
            };

            decimal totalPrice = 0;
            decimal discount = 0;
            var detailDtos = new List<BookingDetailResponseDto>();

            Voucher? voucher = null;
            if (request.VoucherId.HasValue)
            {
                voucher = await _unitOfWork.VoucherRepository
                    .GetByIdAsync(request.VoucherId.Value);

                if (voucher == null)
                    throw new KeyNotFoundException("Voucher không tồn tại");

                var now = DateTime.UtcNow;

                if (voucher.StoreId != request.StoreId)
                    throw new InvalidOperationException("Voucher không hợp lệ cho cửa hàng này");

                if (now < voucher.StartDate)
                    throw new InvalidOperationException("Voucher chưa có hiệu lực");

                if (now > voucher.EndDate)
                    throw new InvalidOperationException("Voucher đã hết hạn");

                if (voucher.UsageLimit > 0 && voucher.UsedCount >= voucher.UsageLimit)
                    throw new InvalidOperationException("Voucher đã hết lượt sử dụng");
            }

            bool matchedServiceVoucher = false;
            var currentStartTime = bookingStartTime;

            for (int i = 0; i < serviceItems.Count; i++)
            {
                var item = serviceItems[i];
                var service = loadedServices[i];

                var startTime = currentStartTime;
                var endTime = startTime.Add(TimeSpan.FromMinutes(service.DurationMinutes));

                var detail = new BookingDetail
                {
                    Booking = booking,
                    ServiceId = item.ServiceId,
                    StaffId = assignedStaffId,
                    AppointmentDate = item.AppointmentDate,
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
                    StaffId = assignedStaffId,
                    AppointmentDate = item.AppointmentDate,
                    StartTime = startTime,
                    EndTime = endTime,
                    Price = service.Price
                });

                if (voucher != null && voucher.ServiceId.HasValue)
                {
                    if (item.ServiceId == voucher.ServiceId.Value)
                    {
                        if (service.Price < voucher.MinOrderValue)
                            throw new InvalidOperationException("Chưa đạt giá trị tối thiểu để áp dụng voucher");

                        discount += CalculateDiscountAmount(service.Price, voucher);
                        matchedServiceVoucher = true;
                    }
                }

                currentStartTime = endTime;
            }

            if (voucher != null && !voucher.ServiceId.HasValue)
            {
                if (totalPrice < voucher.MinOrderValue)
                    throw new InvalidOperationException("Chưa đạt giá trị tối thiểu để áp dụng voucher");

                discount = CalculateDiscountAmount(totalPrice, voucher);
            }

            if (voucher != null && voucher.ServiceId.HasValue && !matchedServiceVoucher)
                throw new InvalidOperationException("Voucher chỉ áp dụng cho dịch vụ cụ thể");

            var finalPrice = totalPrice - discount;
            if (finalPrice < 0) finalPrice = 0;

            if (request.PaymentMethod == PaymentMethod.COD && request.DepositAmount > 0)
                throw new InvalidOperationException("COD không được đi kèm số tiền cọc");

            if (request.DepositAmount > finalPrice)
                throw new InvalidOperationException("Deposit amount không được lớn hơn final price");
                if (voucher != null && discount > 0) 
                {
                    voucher.UsedCount++; 
                    _unitOfWork.VoucherRepository.Update(voucher); 
                }

            booking.TotalPrice = totalPrice;
            booking.DiscountAmount = discount;
            booking.FinalPrice = finalPrice;


            await _unitOfWork.BookingRepository.AddAsync(booking);

            if (request.PaymentMethod == PaymentMethod.COD)
            {
                var payment = new Payment
                {
                    Booking = booking,
                    PaymentMethod = PaymentMethod.COD,
                    PaymentType = PaymentType.Full,
                    Amount = finalPrice,
                    Status = PaymentStatus.Pending
                };

                await _unitOfWork.PaymentRepository.AddAsync(payment);
            }

            await _unitOfWork.SaveChangesAsync();

                var appointmentDateTime = firstItem.AppointmentDate.Date.Add(firstItem.StartTime);
                var reminderTime = appointmentDateTime.AddMinutes(-30);

                var delay = reminderTime - nowVN; 

                if (delay > TimeSpan.Zero)
                {
                 booking.HangfireJobId = BackgroundJob.Schedule<INotificationService>(
                        service => service.SendBookingReminderAsync(booking.Id),
                        delay
                    );
                    _unitOfWork.BookingRepository.Update(booking);
                    await _unitOfWork.SaveChangesAsync();
                }
            await _notificationService.CreateAndSendNotificationAsync(
                customerId,
                "🎉 Đặt lịch thành công",
                $"Bạn đã đặt lịch thành công. Mã đơn: #{booking.Id}. Vui lòng chờ cửa hàng xác nhận nhé!",
                NotificationType.BookingUpdate
            );

            var store = await _unitOfWork.StoreRepository.GetByIdAsync(request.StoreId);
            if (store != null)
            {
                await _notificationService.CreateAndSendNotificationAsync(
                    store.OwnerId,
                    "📅 Có lịch hẹn mới",
                    $"Bạn vừa nhận được một lịch hẹn mới (Mã: #{booking.Id}). Vui lòng kiểm tra và phân công nhân viên!",
                    NotificationType.BookingUpdate 
                );
            }

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

        public async Task<bool> RescheduleBookingAsync(int customerId, int bookingId, RescheduleBookingRequest request)
            {
                var booking = await _unitOfWork.BookingRepository.GetByIdWithDetailsAsync(bookingId);
    
                if (booking == null || booking.CustomerId != customerId)
                throw new KeyNotFoundException("Không tìm thấy đơn đặt lịch của bạn.");

                if (booking.Status != BookingStatus.Pending && booking.Status != BookingStatus.Confirmed)
                    throw new InvalidOperationException("Chỉ có thể dời lịch đối với đơn đang chờ xử lý hoặc đã xác nhận.");

                if (booking.RescheduleCount >= 2)
                    throw new InvalidOperationException("Bạn đã vượt quá số lần dời lịch cho phép (Tối đa 2 lần). Vui lòng hủy đơn nếu không thể đến.");

                var firstDetail = booking.BookingDetails.OrderBy(d => d.StartTime).First();
                var oldBookingDateTime = firstDetail.AppointmentDate.Date.Add(firstDetail.StartTime);
                var nowVN = DateTime.UtcNow.AddHours(7);

                int minHours = await _systemConfigService.GetValueAsync<int>(SystemConfigKeys.BookingMinHours) > 0 
                            ? await _systemConfigService.GetValueAsync<int>(SystemConfigKeys.BookingMinHours) : 2;

                if (oldBookingDateTime < nowVN.AddHours(minHours))
                    throw new InvalidOperationException($"Không thể dời lịch. Hệ thống yêu cầu dời lịch trước tối thiểu {minHours} tiếng.");

                var newBookingDateTime = request.NewAppointmentDate.Date.Add(request.NewStartTime);
                if (newBookingDateTime < nowVN.AddHours(minHours))
                    throw new InvalidOperationException($"Thời gian dời lịch mới không hợp lệ. Phải cách hiện tại ít nhất {minHours} tiếng.");

                var totalDurationMinutes = booking.BookingDetails.Sum(d => (d.EndTime - d.StartTime).TotalMinutes);
                var bookingEndTime = request.NewStartTime.Add(TimeSpan.FromMinutes(totalDurationMinutes));

                var assignedStaffId = await ResolveAssignedStaffIdAsync(
                    booking.StoreId, 
                    request.NewAppointmentDate, 
                    request.NewStartTime, 
                    bookingEndTime, 
                    request.NewStaffId,
                    bookingId);

                booking.RescheduleCount += 1;
                booking.RescheduleReason = request.Reason;
                
                var currentStartTime = request.NewStartTime;
                foreach (var detail in booking.BookingDetails.OrderBy(d => d.Id)) 
                {
                    var duration = detail.EndTime - detail.StartTime;
                    
                    detail.AppointmentDate = request.NewAppointmentDate;
                    detail.StartTime = currentStartTime;
                    detail.EndTime = currentStartTime.Add(duration);
                    detail.StaffId = assignedStaffId;
                    
                    _unitOfWork.BookingDetailRepository.Update(detail);
                    currentStartTime = detail.EndTime;
                }

                _unitOfWork.BookingRepository.Update(booking);

                if (!string.IsNullOrEmpty(booking.HangfireJobId))
                {
                    BackgroundJob.Delete(booking.HangfireJobId); 
                }

                var reminderTime = newBookingDateTime.AddMinutes(-30);
                var delay = reminderTime - nowVN;

                if (delay > TimeSpan.Zero)
                {
                    booking.HangfireJobId = BackgroundJob.Schedule<INotificationService>(
                        service => service.SendBookingReminderAsync(booking.Id),
                        delay
                    );
                }

                await _unitOfWork.SaveChangesAsync();

                await _notificationService.CreateAndSendNotificationAsync(
                    customerId,
                    "🔄 Dời lịch thành công",
                    $"Bạn đã dời lịch đơn #{booking.Id} sang {request.NewStartTime:hh\\:mm} ngày {request.NewAppointmentDate:dd/MM/yyyy}.",
                    NotificationType.BookingUpdate
                );

                var store = await _unitOfWork.StoreRepository.GetByIdAsync(booking.StoreId);
                if (store != null)
                {
                    await _notificationService.CreateAndSendNotificationAsync(
                        store.OwnerId,
                        "🔄 Khách hàng dời lịch",
                        $"Đơn hẹn #{booking.Id} đã được dời sang {request.NewStartTime:hh\\:mm} ngày {request.NewAppointmentDate:dd/MM/yyyy}. Lý do: {request.Reason}",
                        NotificationType.BookingUpdate
                    );
                }

                return true;
            }

        public async Task<List<BookingListItemDto>> GetBookingsByCustomerAsync(int customerId)
        {
            var list = await _unitOfWork.BookingRepository.GetByCustomerAsync(customerId);

            return list
                .OrderByDescending(b => b.CreatedAt)
                .Select(b =>
                {
                    var orderedDetails = b.BookingDetails
                        .OrderBy(d => d.AppointmentDate)
                        .ThenBy(d => d.StartTime)
                        .ToList();

                    var firstDetail = orderedDetails.FirstOrDefault();

                    var mainServiceName = firstDetail?.Service?.Name ?? string.Empty;
                    var extraServiceCount = Math.Max(0, orderedDetails.Count - 1);

                    var successfulPayments = b.Payments
                        .Where(p => p.Status == PaymentStatus.Success)
                        .ToList();

                    var paidAmount = successfulPayments.Sum(p => p.Amount);
                    var remainingAmount = b.FinalPrice - paidAmount;
                    if (remainingAmount < 0) remainingAmount = 0;

                    var appointmentDateTime = firstDetail != null
                        ? firstDetail.AppointmentDate.Date.Add(firstDetail.StartTime)
                        : b.CreatedAt;

                    return new BookingListItemDto
                    {
                        Id = b.Id,
                        CreatedAt = b.CreatedAt,
                        AppointmentDateTime = appointmentDateTime,

                        StoreName = b.Store?.Name ?? string.Empty,
                        StoreAvatarUrl = b.Store?.LogoUrl, 

                        MainServiceName = mainServiceName,
                        ExtraServiceCount = extraServiceCount,
                        ServiceSummary = extraServiceCount > 0
                            ? $"{mainServiceName} + {extraServiceCount} dịch vụ khác"
                            : mainServiceName,

                        StaffName = firstDetail?.Staff?.FullName,
                        StaffAvatarUrl = firstDetail?.Staff?.AvatarUrl,

                        TotalPrice = b.TotalPrice,
                        DiscountAmount = b.DiscountAmount,
                        DepositAmount = b.DepositAmount,
                        FinalPrice = b.FinalPrice,
                        PaidAmount = paidAmount,
                        RemainingAmount = remainingAmount,

                        Status = b.Status
                    };
                })
                .ToList();
        }

        public async Task<BookingDetailDto?> GetBookingByIdAsync(int customerId, int bookingId)
        {
            var booking = await _unitOfWork.BookingRepository
                .GetByIdWithDetailsAsync(bookingId);

            if (booking == null || booking.CustomerId != customerId)
                return null;

            var successfulPayments = booking.Payments
                .Where(p => p.Status == PaymentStatus.Success)
                .ToList();

            var depositPaidAmount = successfulPayments
                .Where(p => p.PaymentType == PaymentType.Deposit)
                .Sum(p => p.Amount);

            var paidAmount = successfulPayments
                .Where(p => p.PaymentType == PaymentType.Full)
                .Sum(p => p.Amount);

            var remainingAmount = booking.FinalPrice - depositPaidAmount - paidAmount;
            if (remainingAmount < 0) remainingAmount = 0;

            return new BookingDetailDto
            {
                Id = booking.Id,
                CreatedAt = booking.CreatedAt,
                TotalPrice = booking.TotalPrice,
                DiscountAmount = booking.DiscountAmount,
                DepositAmount = booking.DepositAmount,
                FinalPrice = booking.FinalPrice,
                Status = booking.Status,
                CustomerNote = booking.CustomerNote,
                StoreName = booking.Store?.Name ?? "",
                DepositPaidAmount = depositPaidAmount,
                PaidAmount = paidAmount,
                RemainingAmount = remainingAmount,
                Services = booking.BookingDetails.Select(d => new BookingServiceDetailDto
                {
                    Id = d.Id,
                    ServiceId = d.ServiceId,
                    ServiceName = d.Service?.Name ?? "",
                    StaffId = d.StaffId,
                    AppointmentDate = d.AppointmentDate,
                    StartTime = d.StartTime,
                    EndTime = d.EndTime,
                    Price = d.Price,
                    Status = d.Status
                }).ToList(),
                Payments = booking.Payments
                    .OrderByDescending(p => p.Id)
                    .Select(p => new PaymentDto
                    {
                        Id = p.Id,
                        Amount = p.Amount,
                        PaymentMethod = p.PaymentMethod,
                        PaymentType = p.PaymentType,
                        Status = p.Status,
                        PaidAt = p.PaidAt
                    }).ToList()
            };
        }

       public async Task<BookingDetailDto> CancelBookingAsync(
            int customerId,
            int bookingId,
            string? reason)
        {
            var booking = await _unitOfWork.BookingRepository
                .GetByIdWithDetailsAsync(bookingId);

            if (booking == null)
                throw new KeyNotFoundException("Booking not found");

            if (booking.CustomerId != customerId)
                throw new UnauthorizedAccessException();

            if (booking.Status == BookingStatus.Cancelled)
                throw new InvalidOperationException("Booking already cancelled");

            if (booking.Status == BookingStatus.Completed)
                throw new InvalidOperationException("Completed booking cannot be cancelled");

            int cancelBeforeHours = await _systemConfigService.GetValueAsync<int>(SystemConfigKeys.CancelBeforeHours);
            if (cancelBeforeHours <= 0) cancelBeforeHours = 3; 

            var firstDetail = booking.BookingDetails
                .OrderBy(d => d.AppointmentDate)
                .ThenBy(d => d.StartTime)
                .FirstOrDefault();

            if (firstDetail == null)
                throw new InvalidOperationException("Booking has no schedule");

            var bookingDateTime = firstDetail.AppointmentDate.Date.Add(firstDetail.StartTime);
            var now = DateTime.UtcNow.AddHours(7); 
            bool isLateCancel = bookingDateTime <= now.AddHours(cancelBeforeHours);

            booking.Status = BookingStatus.Cancelled;
            booking.CancelledBy = CancelledByType.Customer;
            booking.CancelReason = reason;

            foreach (var d in booking.BookingDetails)
            {
                d.Status = BookingDetailStatus.Cancelled;
            }
            bool hasPaidDeposit = false;
            bool isRefunded = false;
            bool isPenaltyApplied = false;

            foreach (var p in booking.Payments.Where(x => x.Status == PaymentStatus.Pending))
            {
                p.Status = PaymentStatus.Refunded; 
            }

            var vnPayDeposit = booking.Payments.FirstOrDefault(p => 
                p.PaymentType == PaymentType.Deposit && 
                p.Status == PaymentStatus.Success);

            if (vnPayDeposit != null && booking.DepositAmount > 0)
            {
                        hasPaidDeposit = true;

                        if (!isLateCancel)
                        {
                            //TRƯỜNG HỢP 1: HỦY SỚM (HOÀN TIỀN VNPAY & THU HỒI VÍ STORE)
                            if (string.IsNullOrEmpty(vnPayDeposit.TransactionId) || !vnPayDeposit.PaidAt.HasValue)
                            {
                                throw new BadRequestException("Giao dịch thiếu TransactionId hoặc PaidAt, không thể hoàn tiền VNPay!");
                            }

                            string vnpPayDateStr = vnPayDeposit.PaidAt.Value.ToString("yyyyMMddHHmmss");

                            var refundResult = await _vnPayService.RefundAsync(
                                vnPayDeposit.TransactionId,
                                vnpPayDateStr,
                                booking.DepositAmount, 
                                $"Customer_{customerId}" 
                            );

                            if (!refundResult.IsSuccess)
                            {
                                throw new BadRequestException($"Hệ thống VNPay từ chối hoàn tiền: {refundResult.Message}");
                            }

                            vnPayDeposit.Status = PaymentStatus.Refunded;
                            isRefunded = true;

                            await _storeWalletService.ClawbackDepositAsync(booking.Id);
                        }
                        else
                        {
                            // TRƯỜNG HỢP 2: HỦY MUỘN (PHẠT CỌC & CỘNG TIỀN CHO STORE/ADMIN)
                            isPenaltyApplied = true;
                            
                            await _storeWalletService.ProcessBookingPenaltyAsync(booking.Id);
                        }
                    }

                    _unitOfWork.BookingRepository.Update(booking);
                    await _unitOfWork.SaveChangesAsync();

                    string customerMsg = $"Bạn đã tự hủy lịch hẹn #{booking.Id}.";
                    string storeMsg = $"Lịch hẹn #{booking.Id} vừa bị khách hàng hủy. Lý do: {reason ?? "Không có lý do"}.";

                    if (hasPaidDeposit)
                    {
                        if (isRefunded)
                        {
                            customerMsg += $" Hủy đúng quy định (trước {cancelBeforeHours}h). Số tiền cọc {booking.DepositAmount:N0}đ đang được xử lý hoàn về thẻ/tài khoản của bạn.";
                            storeMsg += $" Khách hủy đúng quy định, hệ thống đã tự động thu hồi lại tiền cọc từ ví cửa hàng.";
                        }
                        else if (isPenaltyApplied)
                        {
                            customerMsg += $" Hủy quá sát giờ (quy định phải hủy trước {cancelBeforeHours}h). Theo chính sách, bạn không được hoàn lại tiền cọc {booking.DepositAmount:N0}đ.";
                            storeMsg += $" Khách hủy sát giờ, cửa hàng được nhận bồi thường tiền cọc vào ví.";
                        }
                    }

                    await _notificationService.CreateAndSendNotificationAsync(
                        customerId,
                        "Hủy lịch thành công",
                        customerMsg,
                        NotificationType.BookingUpdate
                    );  

                    var store = await _unitOfWork.StoreRepository.GetByIdAsync(booking.StoreId);
                    if (store != null)
                    {
                        await _notificationService.CreateAndSendNotificationAsync(
                            store.OwnerId,
                            "⚠️ Khách hàng tự hủy lịch",
                            storeMsg,
                            NotificationType.BookingUpdate
                        );
                    }

                    var result = await GetBookingByIdAsync(customerId, bookingId);
                    if (result == null) throw new Exception("Cannot load updated booking");

                    return result;
                }

        public async Task<List<AvailableStaffDto>> GetAvailableStaffAsync(GetAvailableStaffRequest request)
        {
            if (request.ServiceIds == null || !request.ServiceIds.Any())
                throw new InvalidOperationException("ServiceIds không được rỗng");

            var services = new List<Service>();
            foreach (var serviceId in request.ServiceIds)
            {
                var service = await _unitOfWork.ServiceRepository.GetByIdAsync(serviceId);
                if (service == null)
                    throw new Exception($"Service {serviceId} not found");

                services.Add(service);
            }

            var totalDurationMinutes = services.Sum(s => s.DurationMinutes);
            var endTime = request.StartTime.Add(TimeSpan.FromMinutes(totalDurationMinutes));

            // Tính toán mốc thời gian DateTime cụ thể để so sánh với Lịch nghỉ phép
            var appointmentDayOfWeek = request.AppointmentDate.DayOfWeek;
            var bookingStartDateTime = request.AppointmentDate.Date.Add(request.StartTime);
            var bookingEndDateTime = request.AppointmentDate.Date.Add(endTime);

            // 1. Lấy danh sách thợ KÈM THEO Lịch và Nghỉ phép
            var staffs = await _unitOfWork.StaffRepository.GetStaffsWithSchedulesAndLeavesAsync(request.StoreId);

            // Lọc điều kiện 1: Thợ đang hoạt động
            var activeStaffs = staffs.Where(s => s.IsActive).ToList();

            // 2. Lọc danh sách thợ ĐANG BẬN BOOKING KHÁC
            var bookingDetails = await _unitOfWork.BookingDetailRepository
                .GetByStoreAndDateAsync(request.StoreId, request.AppointmentDate);

            var busyStaffIds = bookingDetails
                .Where(d =>
                    d.Status != BookingDetailStatus.Cancelled &&
                    d.StartTime < endTime &&
                    d.EndTime > request.StartTime &&
                    d.StaffId != null &&
                    d.BookingId != request.ExcludeBookingId)
                .Select(d => d.StaffId!.Value)
                .Distinct()
                .ToHashSet();

            // 3. KẾT HỢP LỌC CA LÀM, NGHỈ PHÉP VÀ BOOKING
            return activeStaffs
                .Where(s => 
                    !busyStaffIds.Contains(s.Id) &&
                    
                    s.Schedules.Any(sch => 
                        sch.DayOfWeek == appointmentDayOfWeek && 
                        sch.IsWorking && 
                        sch.StartTime <= request.StartTime && 
                        sch.EndTime >= endTime) &&
                        
                    !s.Leaves.Any(l => 
                        l.FromDate < bookingEndDateTime && 
                        l.ToDate > bookingStartDateTime)
                )
                .Select(s => new AvailableStaffDto
                {
                    Id = s.Id,
                    Name = s.FullName,
                    AvatarUrl = s.AvatarUrl
                })
                .ToList();
        }
        private static decimal CalculateDiscountAmount(decimal baseAmount, Voucher voucher)
        {
            decimal discount;

            if (voucher.DiscountType == DiscountType.Percent)
            {
                discount = baseAmount * voucher.DiscountValue / 100m;
            }
            else
            {
                discount = voucher.DiscountValue;
            }

            if (discount > voucher.MaxDiscount)
                discount = voucher.MaxDiscount;

            if (discount > baseAmount)
                discount = baseAmount;

            return Math.Max(0, discount);
        }
      private async Task<int> ResolveAssignedStaffIdAsync(
            int storeId,
            DateTime appointmentDate,
            TimeSpan bookingStartTime,
            TimeSpan bookingEndTime,
            int? requestedStaffId,
            int? excludeBookingId = null)
        {
            var appointmentDayOfWeek = appointmentDate.DayOfWeek;
            var bookingStartDateTime = appointmentDate.Date.Add(bookingStartTime);
            var bookingEndDateTime = appointmentDate.Date.Add(bookingEndTime);

            // 1. Lấy danh sách thợ KÈM THEO Lịch và Nghỉ phép
            var staffs = await _unitOfWork.StaffRepository.GetStaffsWithSchedulesAndLeavesAsync(storeId);
            var activeStaffs = staffs.Where(s => s.IsActive).ToList();

            // 2. Lọc danh sách thợ ĐANG BẬN BOOKING KHÁC
            var bookingDetails = await _unitOfWork.BookingDetailRepository
                .GetByStoreAndDateAsync(storeId, appointmentDate);

            var busyStaffIds = bookingDetails
                .Where(d =>
                    d.Status != BookingDetailStatus.Cancelled &&
                    d.StaffId != null &&
                    d.StartTime < bookingEndTime &&
                    d.EndTime > bookingStartTime &&
                    d.BookingId != excludeBookingId)
                .Select(d => d.StaffId!.Value)
                .Distinct()
                .ToHashSet();

            var availableStaffs = activeStaffs.Where(s => 
                !busyStaffIds.Contains(s.Id) &&
                s.Schedules.Any(sch => 
                    sch.DayOfWeek == appointmentDayOfWeek && 
                    sch.IsWorking && 
                    sch.StartTime <= bookingStartTime && 
                    sch.EndTime >= bookingEndTime) &&
                !s.Leaves.Any(l => 
                    l.FromDate < bookingEndDateTime && 
                    l.ToDate > bookingStartDateTime)
            ).ToList();

            if (requestedStaffId.HasValue)
            {
                var staffId = requestedStaffId.Value;

                if (!activeStaffs.Any(s => s.Id == staffId))
                    throw new InvalidOperationException("Nhân viên không tồn tại hoặc không hoạt động");

                if (busyStaffIds.Contains(staffId))
                    throw new InvalidOperationException("Nhân viên đã có lịch đặt vào khung giờ này");
                    
                if (!availableStaffs.Any(s => s.Id == staffId))
                     throw new InvalidOperationException("Nhân viên không có ca làm việc hoặc đang xin nghỉ phép vào khung giờ này");

                return staffId;
            }

            var availableStaff = availableStaffs.FirstOrDefault();

            if (availableStaff == null)
                throw new InvalidOperationException("Không còn nhân viên phù hợp cho khung giờ này");

            return availableStaff.Id;
        }
        public async Task<bool> MarkAsNoShowAsync(int storeId, int bookingId)
{
    var booking = await _unitOfWork.BookingRepository.GetByIdWithDetailsAsync(bookingId);

    if (booking == null || booking.StoreId != storeId)
        throw new KeyNotFoundException("Không tìm thấy đơn đặt lịch hoặc không có quyền thao tác.");

    if (booking.Status != BookingStatus.Confirmed && booking.Status != BookingStatus.Pending)
        throw new InvalidOperationException("Trạng thái đơn không hợp lệ để đánh dấu No-Show.");

    var firstDetail = booking.BookingDetails
        .OrderBy(d => d.AppointmentDate)
        .ThenBy(d => d.StartTime)
        .FirstOrDefault();

    if (firstDetail == null)
        throw new InvalidOperationException("Đơn đặt lịch không có chi tiết dịch vụ.");

    // LẤY CẤU HÌNH: Thời gian châm chước đi trễ (Grace Period)
    int graceMinutes = await _systemConfigService.GetValueAsync<int>(SystemConfigKeys.GracePeriodMinutes);
    if (graceMinutes <= 0) graceMinutes = 30; 

    var bookingDateTime = firstDetail.AppointmentDate.Date.Add(firstDetail.StartTime);
    var maxAllowedTime = bookingDateTime.AddMinutes(graceMinutes);
    var now = DateTime.UtcNow.AddHours(7); 

    if (now < maxAllowedTime)
    {
        throw new InvalidOperationException($"Chưa hết thời gian giữ chỗ ({graceMinutes} phút). Khách hàng vẫn có thể đến trước {maxAllowedTime:HH:mm}.");
    }

    // UPDATE BOOKING THÀNH NO-SHOW
    booking.Status = BookingStatus.Cancelled; 
    booking.CancelledBy = CancelledByType.Store;
    booking.CancelReason = "Khách hàng không đến (No-Show)";

    foreach (var d in booking.BookingDetails)
    {
        d.Status = BookingDetailStatus.Cancelled;
    }

    foreach (var p in booking.Payments)
    {
        if (p.Status == PaymentStatus.Pending)
        {
            p.Status = PaymentStatus.Failed;
        }
    }

    _unitOfWork.BookingRepository.Update(booking);
     await _unitOfWork.SaveChangesAsync();
 if (booking.CustomerId.HasValue)
    {
    await _notificationService.CreateAndSendNotificationAsync(
        booking.CustomerId.Value,
        "⚠️ Đơn đặt lịch bị hủy",
        $"Lịch hẹn #{booking.Id} đã bị hủy do bạn đến trễ quá thời gian giữ chỗ ({graceMinutes} phút). Vui lòng liên hệ hotline nếu cần hỗ trợ.",
        NotificationType.BookingUpdate
    );
    int currentNoShowCount = await CountCustomerNoShowsAsync(booking.CustomerId.Value);

    int noShowLimit = await _systemConfigService.GetValueAsync<int>(SystemConfigKeys.NoShowLimit);
    if (noShowLimit <= 0) noShowLimit = 3; 
    bool blockUserIfNoShow = await _systemConfigService.GetValueAsync<bool>(SystemConfigKeys.BlockUserIfNoShow);
   
    if (blockUserIfNoShow && currentNoShowCount >= noShowLimit)
    {
        await _notificationService.CreateAndSendNotificationAsync(
            booking.CustomerId.Value,
            "🚫 Tài khoản bị hạn chế đặt lịch",
            $"Tài khoản của bạn đã có {currentNoShowCount} lần không đến đúng hẹn (vượt quá giới hạn {noShowLimit} lần)." 
            + "Bạn sẽ không thể tiếp tục đặt lịch online. Vui lòng liên hệ hotline.",
            NotificationType.SystemAlert
        );
    }
    else
    {
        await _notificationService.CreateAndSendNotificationAsync(
            booking.CustomerId.Value,
            "⚠️ Đơn đặt lịch bị hủy",
            $"Lịch hẹn #{booking.Id} đã bị hủy do bạn không đến. Bạn đã vi phạm {currentNoShowCount}/{noShowLimit} lần."
            +" Nếu vi phạm quá {noShowLimit} lần, tài khoản sẽ bị hạn chế.",
            NotificationType.BookingUpdate
        );
    }
    }
    return true;
}
    private async Task<int> CountCustomerNoShowsAsync(int customerId)
{
    int noShowCount = await _unitOfWork.BookingRepository.GetQueryable()
        .Where(b => b.CustomerId == customerId 
                 && b.Status == BookingStatus.Cancelled 
                 && b.CancelledBy == CancelledByType.Store 
                 && b.CancelReason != null 
                 && b.CancelReason.Contains("No-Show")) 
        .CountAsync();

    return noShowCount;
}
    }
}