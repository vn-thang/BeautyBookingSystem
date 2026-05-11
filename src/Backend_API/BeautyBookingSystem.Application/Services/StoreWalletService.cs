using AutoMapper;
using AutoMapper.QueryableExtensions;
using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.DTOs.Common;
using BeautyBookingSystem.Application.DTOs.StoreWallet;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Constants;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Services
{
    public class StoreWalletService : IStoreWalletService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly INotificationService _notificationService;
        private readonly ICurrentUserService _currentUserService;
        private readonly IStoreVnPayService _vnPayService;

        private const decimal DEFAULT_COMMISSION_RATE = 10m; 

        public StoreWalletService(
            IUnitOfWork unitOfWork, 
            IMapper mapper, 
            INotificationService notificationService, 
            ICurrentUserService currentUserService,
            IStoreVnPayService vnPayService)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _notificationService = notificationService;
            _currentUserService = currentUserService;
            _vnPayService = vnPayService;
        }

        public async Task<WalletBalanceDto> GetWalletBalanceAsync()
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();

            var store = await _unitOfWork.StoreRepository.GetByIdAsync(storeId);
            if (store == null) throw new NotFoundException("Không tìm thấy cửa hàng.");

            return new WalletBalanceDto
            {
                WalletBalance = store.WalletBalance,
                MinimumBalance = store.MinimumBalance,
                IsLockedByDebt = store.WalletBalance <= store.MinimumBalance && !store.IsOpen
            };
        }

       public async Task<WalletDashboardDto> GetWalletDashboardAsync(int? month = null, int? year = null)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();
            var store = await _unitOfWork.StoreRepository.GetQueryable()
                .Include(s => s.Owner) 
                .FirstOrDefaultAsync(s => s.Id == storeId);

            if (store == null) throw new NotFoundException("Không tìm thấy cửa hàng.");

            int targetMonth = month ?? DateTime.UtcNow.Month;
            int targetYear = year ?? DateTime.UtcNow.Year;

            var transactionsThisMonth = await _unitOfWork.WalletTransactionRepository.GetQueryable()
                .Where(t => t.StoreId == storeId 
                        && t.CreatedAt.Month == targetMonth 
                        && t.CreatedAt.Year == targetYear)
                .ToListAsync();

            decimal totalTopUp = transactionsThisMonth
                .Where(t => t.Type == TransactionType.TopUp)
                .Sum(t => t.Amount);

            decimal totalFee = transactionsThisMonth
                .Where(t => t.Type == TransactionType.Commission || t.Type == TransactionType.MonthlyFee)
                .Sum(t => Math.Abs(t.Amount));

            return new WalletDashboardDto
            {
                CurrentBalance = store.WalletBalance,
                MinimumBalance = store.MinimumBalance,
                IsOpen = store.IsOpen,
                TotalTopUpThisMonth = totalTopUp,
                TotalFeeThisMonth = totalFee,
                BankName = store.BankName,
                BankAccountNumber = store.BankAccountNumber,
                BankAccountName = store.BankAccountName,
                OwnerPhone = store.Owner?.Phone 
            };
        }
        public async Task<PagedResponse<WalletTransactionDto>> GetTransactionHistoryAsync(
            int pageIndex, 
            int pageSize, 
            int? month = null, 
            int? year = null, 
            TransactionType? type = null)
            {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();

            var query = _unitOfWork.WalletTransactionRepository.GetQueryable()
                .Where(t => t.StoreId == storeId);

            if (month.HasValue) query = query.Where(t => t.CreatedAt.Month == month.Value);
            if (year.HasValue) query = query.Where(t => t.CreatedAt.Year == year.Value);
            if (type.HasValue) query = query.Where(t => t.Type == type.Value);

            int totalCount = await query.CountAsync();

            var items = await query
    .OrderByDescending(t => t.CreatedAt)
    .Skip((pageIndex - 1) * pageSize)
    .Take(pageSize)
    .Select(t => new WalletTransactionDto
    {
        Id = t.Id,
        BookingId = t.BookingId,
        Amount = t.Amount,
        Type = t.Type,
        BalanceBefore = t.BalanceBefore,
        BalanceAfter = t.BalanceAfter,
        Description = t.Description,
        Status = t.Status.ToString(),
        CreatedAt = t.CreatedAt,
        UpdatedAt = t.UpdatedAt
    })
    .ToListAsync();

            return new PagedResponse<WalletTransactionDto>
            {
                Items = items,
                TotalCount = totalCount,
                TotalPages = (int)Math.Ceiling(totalCount / (double)pageSize)
            };
        }

        public async Task<decimal> ProcessBookingCommissionAsync(int bookingId)
        {
            var booking = await _unitOfWork.BookingRepository.GetQueryable()
                .Include(b => b.Store)
                .FirstOrDefaultAsync(b => b.Id == bookingId);

            if (booking == null) throw new NotFoundException("Không tìm thấy đơn hàng.");
            if (booking.SystemFee > 0) throw new BadRequestException("Đơn hàng này đã được tính phí hoa hồng.");

            var store = booking.Store;
            decimal rate = 0;

            if (store.CommissionRate.HasValue && store.CommissionRate.Value > 0)
            {
                rate = store.CommissionRate.Value;
            }
            else
            {
                var systemRateConfig = await _unitOfWork.SystemConfigRepository.GetQueryable()
                    .FirstOrDefaultAsync(c => c.Key == SystemConfigKeys.DefaultCommissionRate);
                    
                rate = systemRateConfig != null && decimal.TryParse(systemRateConfig.Value, out var parsedRate) 
                       ? parsedRate 
                       : 10m; 
            }

            decimal feeAmount = booking.FinalPrice * (rate / 100m);
            decimal balanceBefore = store.WalletBalance;
            decimal balanceAfter = balanceBefore - feeAmount;

            store.WalletBalance = balanceAfter;
            booking.SystemFee = feeAmount; 

            var transaction = new WalletTransaction
            {
                StoreId = store.Id,
                BookingId = booking.Id,
                Amount = -feeAmount, 
                Type = TransactionType.Commission,
                Status = TransactionStatus.Completed, 
                BalanceBefore = balanceBefore,
                BalanceAfter = balanceAfter,
                Description = $"Trừ {rate}% phí giao dịch cho đơn hàng #{booking.Id}" 
            };

            await _unitOfWork.WalletTransactionRepository.AddAsync(transaction);

            bool isStoreLocked = false;
            if (store.WalletBalance <= store.MinimumBalance && store.IsOpen)
            {
                store.IsOpen = false;
                isStoreLocked = true;
            }
            
            _unitOfWork.StoreRepository.Update(store);
            _unitOfWork.BookingRepository.Update(booking);

            var result = await _unitOfWork.SaveChangesAsync() > 0;
            if (result && isStoreLocked)
            {
                _ = _notificationService.CreateAndSendNotificationAsync(
                    store.OwnerId,
                    "⚠️ Cửa hàng tạm ẩn do hết số dư",
                    $"Ví của bạn đã giảm xuống {store.WalletBalance:N0}đ. Cửa hàng đã tạm thời bị ẩn khỏi hệ thống. Vui lòng nạp thêm tiền để tiếp tục nhận khách.",
                    NotificationType.SystemAlert);
            }

            return feeAmount;
        }

       public async Task<int> ProcessMonthlyAppFeeAsync()
        {
            int processedCount = 0;
            var dueStores = await _unitOfWork.StoreRepository.GetQueryable()
                .Where(s => s.IsOpen && s.NextBillingDate <= DateTime.UtcNow)
                .ToListAsync();

            if (!dueStores.Any()) return 0;
            
            var monthlyFeeConfig = await _unitOfWork.SystemConfigRepository.GetQueryable()
                .FirstOrDefaultAsync(c => c.Key == SystemConfigKeys.DefaultMonthlyAppFee);
                
            decimal defaultMonthlyFee = monthlyFeeConfig != null && decimal.TryParse(monthlyFeeConfig.Value, out var parsedFee) 
                                        ? parsedFee 
                                        : 200000m; 

            foreach (var store in dueStores)
            {
                decimal monthlyFee = store.MonthlyAppFee > 0 
                                     ? store.MonthlyAppFee 
                                     : defaultMonthlyFee; 
                
                decimal balanceBefore = store.WalletBalance;
                decimal balanceAfter = balanceBefore - monthlyFee;
                store.WalletBalance = balanceAfter;

                store.NextBillingDate = store.NextBillingDate?.AddMonths(1) ?? DateTime.UtcNow.AddMonths(1);

                var transaction = new WalletTransaction
                {
                    StoreId = store.Id,
                    Amount = -monthlyFee, 
                    Type = TransactionType.MonthlyFee, 
                    Status = TransactionStatus.Completed, 
                    BalanceBefore = balanceBefore,
                    BalanceAfter = balanceAfter,
                    Description = $"Thu phí duy trì nền tảng tháng {DateTime.UtcNow.Month}/{DateTime.UtcNow.Year}"
                };

                await _unitOfWork.WalletTransactionRepository.AddAsync(transaction);

                bool isStoreLocked = false;
                if (store.WalletBalance <= store.MinimumBalance)
                {
                    store.IsOpen = false;
                    isStoreLocked = true;
                }

                _unitOfWork.StoreRepository.Update(store);
                
                if (isStoreLocked)
                {
                     _ = _notificationService.CreateAndSendNotificationAsync(store.OwnerId, 
                         "⚠️ Cửa hàng bị tạm khóa", 
                         $"Hệ thống vừa thu {monthlyFee:N0}đ phí duy trì. Số dư ví hiện tại là {store.WalletBalance:N0}đ (Vượt mức nợ cho phép). Vui lòng nạp thêm tiền để mở lại.", 
                         NotificationType.SystemAlert);
                }
                else
                {
                     _ = _notificationService.CreateAndSendNotificationAsync(store.OwnerId, 
                         "💳 Thanh toán phí tháng", 
                         $"Hệ thống đã tự động trừ {monthlyFee:N0}đ phí duy trì nền tảng tháng này.", 
                         NotificationType.SystemAlert);
                }
                processedCount++;
            }

            if (processedCount > 0)
            {
                await _unitOfWork.SaveChangesAsync();
            }

            return processedCount;
        }

        public async Task<bool> TopUpWalletAsync(int storeId, decimal amount, string note)
        {
            if (amount <= 0) throw new BadRequestException("Số tiền nạp phải lớn hơn 0.");

            var store = await _unitOfWork.StoreRepository.GetByIdAsync(storeId);
            if (store == null) throw new NotFoundException("Không tìm thấy cửa hàng.");

            decimal balanceBefore = store.WalletBalance;
            decimal balanceAfter = balanceBefore + amount;

            store.WalletBalance = balanceAfter;

            var transaction = new WalletTransaction
            {
                StoreId = store.Id,
                Amount = amount, 
                Type = TransactionType.TopUp,
                Status = TransactionStatus.Completed, 
                BalanceBefore = balanceBefore,
                BalanceAfter = balanceAfter,
                Description = string.IsNullOrWhiteSpace(note) ? "Nạp tiền vào ví" : note
            };

            await _unitOfWork.WalletTransactionRepository.AddAsync(transaction);

            bool isStoreUnlocked = false;
            if (store.WalletBalance > store.MinimumBalance && !store.IsOpen)
            {
                store.IsOpen = true;
                isStoreUnlocked = true;
            }

            _unitOfWork.StoreRepository.Update(store);
            var result = await _unitOfWork.SaveChangesAsync() > 0;

            if (result)
            {
                string message = $"Nạp thành công {amount:N0}đ vào ví.";
                if (isStoreUnlocked) message += " Cửa hàng của bạn đã tự động mở lại!";

                _ = _notificationService.CreateAndSendNotificationAsync(
                    store.OwnerId,
                    "💰 Nạp tiền thành công",
                    message,
                    NotificationType.SystemAlert);
            }

            return result;
        }

        public async Task<string> CreateVnPayTopUpUrlAsync(TopUpRequest request)
        {
            request.StoreId = await _currentUserService.GetCurrentStoreIdAsync();
            return _vnPayService.CreatePaymentUrl(request);
        }

       public async Task<string> ProcessVnPayCallbackAsync()
{
    var response = _vnPayService.PaymentExecute();

    if (!response.Success)
    {
        throw new BadRequestException("Giao dịch nạp tiền qua VNPay thất bại hoặc chữ ký không hợp lệ.");
    }

    string expectedNote = $"Nạp tiền qua VNPay. Mã GD: {response.TransactionId}";

    bool isAlreadyProcessed = await _unitOfWork.WalletTransactionRepository
        .GetQueryable()
        .AnyAsync(t => t.Description == expectedNote && t.Type == TransactionType.TopUp);

    if (isAlreadyProcessed)
    {
        return $"beautybooking://payment-result?success=true&amount={response.Amount}";
    }
    int storeId = int.Parse(response.OrderId.Split('_')[0]);
    decimal amount = response.Amount; 

    await TopUpWalletAsync(storeId, amount, expectedNote);
    
    return $"beautybooking://payment-result?success=true&amount={amount}";
}

        public async Task<decimal> ProcessBookingPenaltyAsync(int bookingId)
        {
            var booking = await _unitOfWork.BookingRepository.GetQueryable()
                .Include(b => b.Store)
                .FirstOrDefaultAsync(b => b.Id == bookingId);

            if (booking == null) throw new NotFoundException("Không tìm thấy đơn hàng.");
            if (booking.DepositAmount <= 0) return 0; 
            var store = booking.Store;
            var penaltyConfig = await _unitOfWork.SystemConfigRepository.GetQueryable()
                .FirstOrDefaultAsync(c => c.Key == "PenaltyCommissionPercent");
            
            decimal adminRate = penaltyConfig != null && decimal.TryParse(penaltyConfig.Value, out var parsedRate) 
                                ? parsedRate : 20m; 

            decimal adminFee = booking.DepositAmount * (adminRate / 100m);
            decimal storeEarn = booking.DepositAmount - adminFee;

            decimal balanceBefore = store.WalletBalance;
            decimal balanceAfter = balanceBefore + storeEarn;
            store.WalletBalance = balanceAfter;

            var transaction = new WalletTransaction
            {
                StoreId = store.Id,
                BookingId = booking.Id,
                Amount = storeEarn, 
                Type = TransactionType.TopUp, 
                Status = TransactionStatus.Completed, 
                BalanceBefore = balanceBefore,
                BalanceAfter = balanceAfter,
                Description = $"Bồi thường hủy lịch sát giờ đơn #{booking.Id}. " + 
                              $"(Cọc: {booking.DepositAmount:N0}đ, Trừ phí hệ thống {adminRate}%: -{adminFee:N0}đ)"
            };

            await _unitOfWork.WalletTransactionRepository.AddAsync(transaction);
            if (store.WalletBalance > store.MinimumBalance && !store.IsOpen)
            {
                store.IsOpen = true;
            }
            _unitOfWork.StoreRepository.Update(store);
            await _unitOfWork.SaveChangesAsync();

            return storeEarn;
        }

        public async Task ReceiveDepositAsync(int bookingId)
        {
            var booking = await _unitOfWork.BookingRepository.GetByIdAsync(bookingId);
            if (booking == null) throw new NotFoundException("Không tìm thấy đơn đặt lịch.");
            if (booking.DepositAmount <= 0) return; 

            var store = await _unitOfWork.StoreRepository.GetByIdAsync(booking.StoreId);
            if (store == null) throw new NotFoundException("Không tìm thấy cửa hàng.");

            decimal balanceBefore = store.WalletBalance;
            decimal balanceAfter = balanceBefore + booking.DepositAmount;

            store.WalletBalance = balanceAfter;
            var transaction = new WalletTransaction
            {
                StoreId = store.Id,
                BookingId = booking.Id,
                Amount = booking.DepositAmount,
                Type = TransactionType.ReceiveDeposit, 
                Status = TransactionStatus.Completed, 
                BalanceBefore = balanceBefore,
                BalanceAfter = balanceAfter,
                Description = $"Nhận tiền cọc từ đơn đặt lịch #{booking.Id}"
            };

            await _unitOfWork.WalletTransactionRepository.AddAsync(transaction);
            if (store.WalletBalance > store.MinimumBalance && !store.IsOpen)
            {
                store.IsOpen = true;
            }

            _unitOfWork.StoreRepository.Update(store);
            await _unitOfWork.SaveChangesAsync();
        }

        public async Task ClawbackDepositAsync(int bookingId)
        {
            var booking = await _unitOfWork.BookingRepository.GetByIdAsync(bookingId);
            if (booking == null) throw new NotFoundException("Không tìm thấy đơn đặt lịch.");
            if (booking.DepositAmount <= 0) return; 

            var store = await _unitOfWork.StoreRepository.GetByIdAsync(booking.StoreId);
            if (store == null) throw new NotFoundException("Không tìm thấy cửa hàng.");

            decimal balanceBefore = store.WalletBalance;
            decimal balanceAfter = balanceBefore - booking.DepositAmount;
            store.WalletBalance = balanceAfter;

            var transaction = new WalletTransaction
            {
                StoreId = store.Id,
                BookingId = booking.Id,
                Amount = booking.DepositAmount, 
                Type = TransactionType.ClawbackDeposit, 
                Status = TransactionStatus.Completed,
                BalanceBefore = balanceBefore,
                BalanceAfter = balanceAfter,
                Description = $"Thu hồi tiền cọc do hủy đơn đặt lịch #{booking.Id}"
            };

            await _unitOfWork.WalletTransactionRepository.AddAsync(transaction);

            if (store.WalletBalance <= store.MinimumBalance && store.IsOpen)
            {
                store.IsOpen = false;
            
                _ = _notificationService.CreateAndSendNotificationAsync(
                    store.OwnerId,
                    "⚠️ Cửa hàng tạm đóng",
                    "Số dư ví của bạn đã rớt xuống dưới mức tối thiểu do thu hồi tiền cọc. Hệ thống đã tạm ẩn cửa hàng. Vui lòng nạp thêm tiền để tiếp tục nhận khách!",
                    NotificationType.SystemAlert);
            }
            _unitOfWork.StoreRepository.Update(store);
            await _unitOfWork.SaveChangesAsync();
        }
    }
}