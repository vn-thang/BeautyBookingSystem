using BeautyBookingSystem.Application.DTOs.Booking;
using BeautyBookingSystem.Application.DTOs.Staff;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Domain.Enums;
using System;

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
            throw new Exception("Danh sách dịch vụ không được rỗng");

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
        var detailDtos = new List<BookingDetailResponseDto>();

        var currentStartTime = request.Services.First().StartTime;

        foreach (var item in request.Services)
        {
            var service = await _unitOfWork.ServiceRepository
                .GetByIdAsync(item.ServiceId);

            if (service == null)
                throw new KeyNotFoundException("Service not found");

            var startTime = currentStartTime;
            var endTime = startTime.Add(TimeSpan.FromMinutes(service.DurationMinutes));

            var conflict = await _unitOfWork.BookingDetailRepository
                .IsStaffBusy(item.StaffId, item.AppointmentDate, startTime, endTime);

            if (conflict)
                throw new Exception("Staff already booked");

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

            currentStartTime = endTime;
        }

        decimal discount = 0;

        if (request.VoucherId.HasValue)
        {
            var voucher = await _unitOfWork.VoucherRepository
                .GetByIdAsync(request.VoucherId.Value);

            if (voucher == null)
                throw new Exception("Voucher không tồn tại");

            var now = DateTime.UtcNow;

            if (voucher.StoreId != request.StoreId)
                throw new Exception("Voucher không hợp lệ cho cửa hàng này");

            if (now < voucher.StartDate)
                throw new Exception("Voucher chưa có hiệu lực");

            if (now > voucher.EndDate)
                throw new Exception("Voucher đã hết hạn");

            if (voucher.UsageLimit > 0 &&
                voucher.UsedCount >= voucher.UsageLimit)
            {
                throw new Exception("Voucher đã hết lượt sử dụng");
            }

            // Voucher chỉ dành cho service cụ thể
            // Nếu ServiceId == null => voucher cho toàn store
            if (voucher.ServiceId.HasValue)
            {
                var hasService = request.Services
                    .Any(s => s.ServiceId == voucher.ServiceId.Value);

                if (!hasService)
                    throw new Exception("Voucher chỉ áp dụng cho dịch vụ cụ thể");
            }

            if (totalPrice < voucher.MinOrderValue)
                throw new Exception("Chưa đạt giá trị tối thiểu để áp dụng voucher");

            if (voucher.DiscountType == DiscountType.Percent)
            {
                discount = totalPrice * voucher.DiscountValue / 100;
            }
            else
            {
                discount = voucher.DiscountValue;
            }

            if (discount > voucher.MaxDiscount)
                discount = voucher.MaxDiscount;

            voucher.UsedCount += 1;
            _unitOfWork.VoucherRepository.Update(voucher);
        }

        var finalPrice = totalPrice - discount;

        if (booking.DepositAmount < 0)
            throw new Exception("Deposit amount không hợp lệ");

        if (booking.DepositAmount > finalPrice)
            throw new Exception("Deposit amount không được lớn hơn final price");

        booking.TotalPrice = totalPrice;
        booking.DiscountAmount = discount;
        booking.FinalPrice = finalPrice;

        await _unitOfWork.BookingRepository.AddAsync(booking);

        var payment = new Payment
        {
            Booking = booking,
            PaymentMethod = request.PaymentMethod,
            PaymentType = PaymentType.Full,
            Amount = booking.FinalPrice,
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

    public async Task<List<BookingListItemDto>> GetBookingsByCustomerAsync(int customerId)
    {
        var list = await _unitOfWork.BookingRepository.GetByCustomerAsync(customerId);

        return list.Select(b => new BookingListItemDto
        {
            Id = b.Id,
            CreatedAt = b.CreatedAt,
            DepositAmount = b.DepositAmount,
            FinalPrice = b.FinalPrice,
            StoreName = b.Store?.Name ?? string.Empty,
            Status = b.Status
        }).ToList();
    }

    public async Task<BookingDetailDto?> GetBookingByIdAsync(int customerId, int bookingId)
    {
        var booking = await _unitOfWork.BookingRepository
            .GetByIdWithDetailsAsync(bookingId);

        if (booking == null || booking.CustomerId != customerId)
            return null;

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
            Payments = booking.Payments.Select(p => new PaymentDto
            {
                Id = p.Id,
                Amount = p.Amount,
                PaymentMethod = p.PaymentMethod,
                Status = p.Status,
                PaidAt = p.PaidAt
            }).ToList()
        };
    }

    public async Task CancelBookingAsync(int customerId, int bookingId, string? reason)
    {
        var booking = await _unitOfWork.BookingRepository
            .GetByIdWithDetailsAsync(bookingId);

        if (booking == null)
            throw new KeyNotFoundException("Booking not found");

        if (booking.CustomerId != customerId)
            throw new UnauthorizedAccessException();

        if (booking.Status != BookingStatus.Pending)
            throw new Exception("Only pending booking can cancel");

        booking.Status = BookingStatus.Cancelled;
        booking.CancelledBy = CancelledByType.Customer;
        booking.CancelReason = reason;

        foreach (var d in booking.BookingDetails)
        {
            d.Status = BookingDetailStatus.Cancelled;
        }

        foreach (var p in booking.Payments)
        {
            if (p.Status == PaymentStatus.Pending)
                p.Status = PaymentStatus.Refunded;
        }

        _unitOfWork.BookingRepository.Update(booking);
        await _unitOfWork.SaveChangesAsync();
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
}