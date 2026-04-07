using BeautyBookingSystem.Application.DTOs.Booking;
using BeautyBookingSystem.Application.DTOs.Staff;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Domain.Enums;

namespace BeautyBookingSystem.Application.Services
{
    public class BookingService : IBookingService
    {
        private readonly IUnitOfWork _unitOfWork;

        public BookingService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
        }

        public async Task<BookingResponseDto> CreateBookingAsync(
            int customerId,
            CreateBookingRequest request)
        {
            if (request.Services == null || !request.Services.Any())
                throw new InvalidOperationException("Danh sách dịch vụ không được rỗng");

            if (request.DepositAmount < 0)
                throw new InvalidOperationException("Deposit amount không hợp lệ");

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

            var currentStartTime = request.Services.First().StartTime;

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

            foreach (var item in request.Services)
            {
                var service = await _unitOfWork.ServiceRepository.GetByIdAsync(item.ServiceId);
                if (service == null)
                    throw new KeyNotFoundException("Service not found");

                var startTime = currentStartTime;
                var endTime = startTime.Add(TimeSpan.FromMinutes(service.DurationMinutes));

                var conflict = await _unitOfWork.BookingDetailRepository
                    .IsStaffBusy(item.StaffId, item.AppointmentDate, startTime, endTime);

                if (conflict)
                    throw new InvalidOperationException("Staff already booked");

                var detail = new BookingDetail
                {
                    Booking = booking,
                    ServiceId = item.ServiceId,
                    StaffId = item.StaffId,
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
                    StaffId = item.StaffId,
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

            booking.TotalPrice = totalPrice;
            booking.DiscountAmount = discount;
            booking.FinalPrice = finalPrice;

            await _unitOfWork.BookingRepository.AddAsync(booking);

            // COD thì tạo payment luôn
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

            // VNPay: không tạo payment ở đây, chỉ tạo ở /payments/vnpay/create
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

            // 🔥 RULE 24H 
            var firstDetail = booking.BookingDetails
                .OrderBy(d => d.AppointmentDate)
                .ThenBy(d => d.StartTime)
                .FirstOrDefault();

            if (firstDetail == null)
                throw new InvalidOperationException("Booking has no schedule");

            var bookingDateTime = firstDetail.AppointmentDate
                .Date
                .Add(firstDetail.StartTime);

            var now = DateTime.UtcNow.AddHours(7); // VN timezone

            if (bookingDateTime <= now.AddHours(24))
                throw new InvalidOperationException("Chỉ được hủy trước 24 giờ của lịch hẹn");

            // UPDATE BOOKING
            booking.Status = BookingStatus.Cancelled;
            booking.CancelledBy = CancelledByType.Customer;
            booking.CancelReason = reason;

            // cancel all booking details
            foreach (var d in booking.BookingDetails)
            {
                d.Status = BookingDetailStatus.Cancelled;
            }


            // PAYMENT HANDLING

            foreach (var p in booking.Payments)
            {
                if (p.Status == PaymentStatus.Pending)
                {
                    // ❗ pending -> failed (đúng hơn refunded)
                    p.Status = PaymentStatus.Failed;
                }
                else if (p.Status == PaymentStatus.Success)
                {
                    //  nếu đã thanh toán thì xử lý refund logic sau
                    // tạm thời giữ nguyên hoặc đánh dấu cần refund
                    // p.Status = PaymentStatus.Refunded; (nếu bạn có flow refund)
                }
            }

            _unitOfWork.BookingRepository.Update(booking);
            await _unitOfWork.SaveChangesAsync();


            // RETURN UPDATED DTO
            var result = await GetBookingByIdAsync(customerId, bookingId);

            if (result == null)
                throw new Exception("Cannot load updated booking");

            return result;
        }

        public async Task<List<AvailableStaffDto>> GetAvailableStaffAsync(GetAvailableStaffRequest request)
        {
            var service = await _unitOfWork.ServiceRepository.GetByIdAsync(request.ServiceId);

            if (service == null)
                throw new Exception("Service not found");

            var endTime = request.StartTime.Add(TimeSpan.FromMinutes(service.DurationMinutes));

            var staffs = await _unitOfWork.StaffRepository.GetByStoreIdAsync(request.StoreId);
            staffs = staffs.Where(s => s.IsActive).ToList();

            var bookingDetails = await _unitOfWork.BookingDetailRepository
                .GetByStoreAndDateAsync(request.StoreId, request.AppointmentDate);

            var busyStaffIds = bookingDetails
                .Where(d =>
                    d.Status != BookingDetailStatus.Cancelled &&
                    d.StartTime < endTime &&
                    d.EndTime > request.StartTime &&
                    d.StaffId != null
                )
                .Select(d => d.StaffId!.Value)
                .Distinct()
                .ToList();

            var availableStaff = staffs
                .Where(s => !busyStaffIds.Contains(s.Id))
                .Select(s => new AvailableStaffDto
                {
                    Id = s.Id,
                    Name = s.FullName,
                    AvatarUrl = s.AvatarUrl
                })
                .ToList();

            return availableStaff;
        }
        private static decimal CalculateDiscountAmount(decimal baseAmount, Voucher voucher)
        {
            decimal discount;

            if (voucher.DiscountType == DiscountType.Percent ||
                voucher.DiscountType == DiscountType.Percent)
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
    }
}