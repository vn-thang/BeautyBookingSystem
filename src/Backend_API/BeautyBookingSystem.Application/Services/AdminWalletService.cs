using BeautyBookingSystem.Application.DTOs.Common;
using BeautyBookingSystem.Application.DTOs.AdminWallet;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.EntityFrameworkCore;
using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Domain.Entities;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using BeautyBookingSystem.Application.DTOs.StoreWallet; 

namespace BeautyBookingSystem.Application.Services
{
    public class AdminWalletService : IAdminWalletService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper; 

        public AdminWalletService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<PagedResponse<AdminWalletTransactionDto>> GetAllTransactionsAsync(
            int pageIndex, 
            int pageSize, 
            DateTime? startDate = null, 
            DateTime? endDate = null, 
            string? storeName = null, 
            TransactionType? type = null)
        {
            var query = _unitOfWork.WalletTransactionRepository.GetQueryable()
                .AsNoTracking(); 

            if (startDate.HasValue)
            {
                query = query.Where(t => t.CreatedAt >= startDate.Value);
            }

            if (endDate.HasValue)
            {
                var endOfDay = endDate.Value.Date.AddDays(1).AddTicks(-1);
                query = query.Where(t => t.CreatedAt <= endOfDay);
            }

            if (type.HasValue)
            {
                query = query.Where(t => t.Type == type.Value);
            }

            if (!string.IsNullOrWhiteSpace(storeName))
            {
                query = query.Where(t => t.Store.Name.Contains(storeName));
            }

            int totalCount = await query.CountAsync();

            var items = await query
                .OrderByDescending(t => t.CreatedAt)
                .Skip((pageIndex - 1) * pageSize)
                .Take(pageSize)
                .ProjectTo<AdminWalletTransactionDto>(_mapper.ConfigurationProvider) 
                .ToListAsync();

           var totalPages = (int)Math.Ceiling(totalCount / (double)pageSize);

            return new PagedResponse<AdminWalletTransactionDto>
            {
                Items = items,
                TotalCount = totalCount,
                TotalPages = totalPages,
                PageIndex = pageIndex,
                PageSize = pageSize,
            };
        }

        public async Task<bool> AdjustStoreWalletBalanceAsync(int storeId, AdjustWalletRequest request)
        {
            var store = await _unitOfWork.StoreRepository.GetByIdAsync(storeId);
            if (store == null) throw new NotFoundException("Không tìm thấy cửa hàng.");

            if (request.Amount <= 0) 
                throw new BadRequestException("Số tiền điều chỉnh phải lớn hơn 0.");

            decimal balanceBefore = store.WalletBalance;
            decimal balanceAfter = request.Type == TransactionType.TopUp 
                ? balanceBefore + request.Amount 
                : balanceBefore - request.Amount;

            store.WalletBalance = balanceAfter;
            _unitOfWork.StoreRepository.Update(store);

            var transaction = _mapper.Map<WalletTransaction>(request);
            
            transaction.StoreId = storeId;
            transaction.BalanceBefore = balanceBefore;
            transaction.BalanceAfter = balanceAfter;
            transaction.CreatedAt = DateTime.UtcNow;

            await _unitOfWork.WalletTransactionRepository.AddAsync(transaction);

            return await _unitOfWork.SaveChangesAsync() > 0;
        }

  public async Task<PagedResponse<WithdrawalRequestDto>> GetPendingWithdrawalsAsync(
            int pageIndex, 
            int pageSize, 
            string? storeName = null)
{
    var query = _unitOfWork.WithdrawalRequestRepository.GetQueryable()
        .AsNoTracking()
        .Where(t => t.Status == WithdrawalStatus.Pending); 

    if (!string.IsNullOrWhiteSpace(storeName))
    {
        query = query.Where(t => t.Store.Name.Contains(storeName));
    }

    int totalCount = await query.CountAsync();

    var items = await query
        .OrderBy(t => t.CreatedAt) 
        .Skip((pageIndex - 1) * pageSize)
        .Take(pageSize)
        .ProjectTo<WithdrawalRequestDto>(_mapper.ConfigurationProvider)
        .ToListAsync();

    var totalPages = (int)Math.Ceiling(totalCount / (double)pageSize);

    return new PagedResponse<WithdrawalRequestDto>
    {
        Items = items,
        TotalCount = totalCount,
        TotalPages = totalPages,
        PageIndex = pageIndex,
        PageSize = pageSize,
    };
}

public async Task<PagedResponse<WithdrawalRequestDto>> GetProcessedWithdrawalsAsync(
    int pageIndex, int pageSize, string? storeName = null)
{
    var query = _unitOfWork.WithdrawalRequestRepository.GetQueryable()
        .AsNoTracking()
        .Where(t => t.Status != WithdrawalStatus.Pending); 

    if (!string.IsNullOrWhiteSpace(storeName))
    {
        query = query.Where(t => t.Store.Name.Contains(storeName));
    }

    int totalCount = await query.CountAsync();
    var items = await query
        .OrderByDescending(t => t.CreatedAt) 
        .Skip((pageIndex - 1) * pageSize)
        .Take(pageSize)
        .ProjectTo<WithdrawalRequestDto>(_mapper.ConfigurationProvider)
        .ToListAsync();

    return new PagedResponse<WithdrawalRequestDto>
    {
        Items = items, TotalCount = totalCount, TotalPages = (int)Math.Ceiling(totalCount / (double)pageSize), PageIndex = pageIndex, PageSize = pageSize
    };
}

        public async Task<bool> ApproveWithdrawalAsync(int requestId, ApproveWithdrawalDto requestDto)
{
    var request = await _unitOfWork.WithdrawalRequestRepository.GetByIdAsync(requestId);
    if (request == null) throw new NotFoundException("Không tìm thấy yêu cầu rút tiền.");
    if (request.Status != WithdrawalStatus.Pending) throw new BadRequestException("Yêu cầu này đã được xử lý.");

    request.Status = WithdrawalStatus.Approved;
    request.ReceiptImageUrl = requestDto.ReceiptImageUrl;
    _unitOfWork.WithdrawalRequestRepository.Update(request);

    var transaction = await _unitOfWork.WalletTransactionRepository.GetQueryable()
        .Where(t => t.StoreId == request.StoreId && t.Type == TransactionType.Withdrawal && t.Status == TransactionStatus.Pending)
        .OrderByDescending(t => t.CreatedAt).FirstOrDefaultAsync();

    if (transaction != null)
    {
        transaction.Status = TransactionStatus.Completed;
        if (!string.IsNullOrWhiteSpace(requestDto.ReceiptImageUrl))
            transaction.Description += $" [Biên lai: {requestDto.ReceiptImageUrl}]";
        _unitOfWork.WalletTransactionRepository.Update(transaction);
    }

    return await _unitOfWork.SaveChangesAsync() > 0;
}

public async Task<bool> RejectWithdrawalAsync(int requestId, RejectWithdrawalDto requestDto)
{
    if (string.IsNullOrWhiteSpace(requestDto.AdminNote))
        throw new BadRequestException("Bắt buộc phải nhập lý do từ chối.");

    var request = await _unitOfWork.WithdrawalRequestRepository.GetByIdAsync(requestId);
    if (request == null) throw new NotFoundException("Không tìm thấy yêu cầu rút tiền.");
    if (request.Status != WithdrawalStatus.Pending) throw new BadRequestException("Yêu cầu này đã được xử lý.");

    request.Status = WithdrawalStatus.Rejected;
    request.AdminNote = requestDto.AdminNote;
    _unitOfWork.WithdrawalRequestRepository.Update(request);

    var store = await _unitOfWork.StoreRepository.GetByIdAsync(request.StoreId);
    decimal balanceBefore = store!.WalletBalance;
    decimal balanceAfter = balanceBefore + request.Amount; 
    store.WalletBalance = balanceAfter;
    _unitOfWork.StoreRepository.Update(store);

    var transaction = await _unitOfWork.WalletTransactionRepository.GetQueryable()
        .Where(t => t.StoreId == request.StoreId && t.Type == TransactionType.Withdrawal && t.Status == TransactionStatus.Pending)
        .OrderByDescending(t => t.CreatedAt).FirstOrDefaultAsync();

    if (transaction != null)
    {
        transaction.Status = TransactionStatus.Failed;
        transaction.Description += $" [BỊ TỪ CHỐI: {requestDto.AdminNote}]";
        _unitOfWork.WalletTransactionRepository.Update(transaction);
    }

    var refundTransaction = new WalletTransaction
    {
        StoreId = store.Id,
        Type = TransactionType.Refund,
        Amount = request.Amount,
        BalanceBefore = balanceBefore,
        BalanceAfter = balanceAfter,
        Status = TransactionStatus.Completed,
        Description = $"Hoàn tiền lệnh rút #{requestId} bị từ chối. Lý do: {requestDto.AdminNote}",
        CreatedAt = DateTime.UtcNow
    };
    await _unitOfWork.WalletTransactionRepository.AddAsync(refundTransaction);

    return await _unitOfWork.SaveChangesAsync() > 0;
}
    }
}