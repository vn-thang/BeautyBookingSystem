using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.DTOs.StoreBilling;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Services
{
    public class StoreBillingService : IStoreBillingService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUserService _currentUserService;

        public StoreBillingService(IUnitOfWork unitOfWork, ICurrentUserService currentUserService)
        {
            _unitOfWork = unitOfWork;
            _currentUserService = currentUserService;
        }

     public async Task<BookingBillDetailDto> GetBillDetailAsync(int bookingId)
{
    int storeId = await _currentUserService.GetCurrentStoreIdAsync();
    var booking = await _unitOfWork.BookingRepository.GetQueryable()
        .Include(b => b.Store)
        .Include(b => b.Customer)
        .Include(b => b.BookingDetails)
            .ThenInclude(bd => bd.Service) 
        .FirstOrDefaultAsync(b => b.Id == bookingId && b.StoreId == storeId);

    if (booking == null)
        throw new NotFoundException("Không tìm thấy đơn hàng này hoặc đơn hàng không thuộc cửa hàng của bạn!");

    var billDto = new BookingBillDetailDto
    {
        StoreName = booking.Store?.Name ?? "Tên Cửa Hàng",
        StoreAddress = booking.Store?.Address ?? "Địa chỉ cửa hàng",
        StorePhone = booking.Store?.Phone ?? "SĐT cửa hàng",
        
        BookingId = booking.Id,
        CreatedAt = booking.CreatedAt, 
        CustomerName = booking.Customer?.FullName ?? "Khách vãng lai",
        CustomerPhone = booking.Customer?.Phone ?? string.Empty,

        Services = booking.BookingDetails.Select(bd => new BillServiceItemDto
        {
            ServiceName = bd.Service?.Name ?? "Dịch vụ",
            Quantity = 1,
            UnitPrice = bd.Price,
            TotalPrice = bd.Price 
        }).ToList(),

        SubTotal = booking.TotalPrice,
        DiscountAmount = booking.DiscountAmount,
        FinalTotal = booking.FinalPrice,
        DepositAmount = booking.DepositAmount,
        AmountToPay = Math.Max(0, booking.FinalPrice - booking.DepositAmount)
    };

    return billDto;
}
    }
}