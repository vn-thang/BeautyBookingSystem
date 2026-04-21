// Vị trí: Application/Services/WithdrawalService.cs
using AutoMapper;
using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.DTOs.StoreWallet;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using FirebaseAdmin.Auth;

namespace BeautyBookingSystem.Application.Services
{
    public class WithdrawalService : IWithdrawalService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly ICurrentUserService _currentUserService;

        public WithdrawalService(IUnitOfWork unitOfWork, IMapper mapper, ICurrentUserService currentUserService)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _currentUserService = currentUserService;
        }
        public async Task<bool> CreateRequestAsync(CreateWithdrawalDto dto)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();

            var store = await _unitOfWork.StoreRepository.GetByIdAsync(storeId);
            if (store == null) 
                throw new BadRequestException("Không tìm thấy cửa hàng.");

            if (string.IsNullOrEmpty(dto.FirebaseIdToken))
            throw new BadRequestException("Yêu cầu mã xác thực OTP để rút tiền.");

            FirebaseToken decodedToken;
            try
            {
                decodedToken = await FirebaseAuth.DefaultInstance.VerifyIdTokenAsync(dto.FirebaseIdToken);
            }
            catch (Exception)
            {
                throw new BadRequestException("Mã xác thực OTP không hợp lệ hoặc đã hết hạn.");
            }

            string verifiedPhone = decodedToken.Claims.TryGetValue("phone_number", out var phoneObj) 
                                ? phoneObj.ToString()! : "";

            if (string.IsNullOrEmpty(verifiedPhone))
                throw new BadRequestException("Không lấy được số điện thoại từ hệ thống xác thực.");

            var owner = await _unitOfWork.UserRepository.GetByIdAsync(store.OwnerId);
            if (owner == null)
                throw new BadRequestException("Không tìm thấy thông tin chủ cửa hàng.");

            if (owner.Phone != verifiedPhone)
            {
                throw new BadRequestException("Số điện thoại xác thực OTP không khớp với số điện thoại của tài khoản chủ cửa hàng.");
            }

            ValidateStoreForWithdrawal(store, dto.Amount);

            decimal balanceBefore = store.WalletBalance;
            store.WalletBalance -= dto.Amount; 

            var transaction = new WalletTransaction
            {
                StoreId = storeId,
                Amount = -dto.Amount,
                Type = TransactionType.Withdrawal, 
                Status = TransactionStatus.Pending, 
                BalanceBefore = balanceBefore,
                BalanceAfter = store.WalletBalance,
                Description = $"Rút tiền về TK {store.BankName} - {store.BankAccountNumber}"
            };
            var request = new WithdrawalRequest
            {
                StoreId = storeId,
                Amount = dto.Amount,
                BankName = store.BankName!,
                BankAccountNumber = store.BankAccountNumber!,
                BankAccountName = store.BankAccountName!,
                Status = WithdrawalStatus.Pending
            };

            await _unitOfWork.WalletTransactionRepository.AddAsync(transaction);
            await _unitOfWork.WithdrawalRequestRepository.AddAsync(request);
            _unitOfWork.StoreRepository.Update(store);

            return await _unitOfWork.SaveChangesAsync() > 0;
        }
       public async Task<bool> ApproveRequestAsync(int requestId, ApproveWithdrawalDto dto)
{
    if (string.IsNullOrWhiteSpace(dto.ReceiptImageUrl))
    {
        throw new BadRequestException("Vui lòng tải lên hình ảnh biên lai chuyển khoản thành công từ ngân hàng."); 
    }

    int adminId = _currentUserService.GetUserId();

    var request = await _unitOfWork.WithdrawalRequestRepository.GetByIdAsync(requestId);
    ValidatePendingRequest(request);
    request!.Status = WithdrawalStatus.Approved;
    request.ReceiptImageUrl = dto.ReceiptImageUrl;
    request.ProcessedByAdminId = adminId;
    request.ProcessedAt = DateTime.Now;
    var pendingTransaction = await _unitOfWork.WalletTransactionRepository.GetQueryable()
        .Where(t => t.StoreId == request.StoreId 
                 && t.Type == TransactionType.Withdrawal 
                 && t.Status == TransactionStatus.Pending
                 && t.Amount == -request.Amount)
        .OrderByDescending(t => t.CreatedAt)
        .FirstOrDefaultAsync();

    if (pendingTransaction != null)
    {
        pendingTransaction.Status = TransactionStatus.Completed; 
        _unitOfWork.WalletTransactionRepository.Update(pendingTransaction);
    }

    _unitOfWork.WithdrawalRequestRepository.Update(request);
    return await _unitOfWork.SaveChangesAsync() > 0;
}
        public async Task<bool> RejectRequestAsync(int requestId, RejectWithdrawalDto dto)
        {
            int adminId = _currentUserService.GetUserId();

            var request = await _unitOfWork.WithdrawalRequestRepository.GetByIdAsync(requestId);
            ValidatePendingRequest(request);

            var store = await _unitOfWork.StoreRepository.GetByIdAsync(request!.StoreId);
            if (store == null) 
                throw new BadRequestException("Không tìm thấy cửa hàng của yêu cầu này.");

            // Hoàn lại tiền vào ví
            decimal balanceBefore = store.WalletBalance;
            store.WalletBalance += request.Amount;
            var pendingTransaction = await _unitOfWork.WalletTransactionRepository.GetQueryable()
                .Where(t => t.StoreId == request.StoreId 
                         && t.Type == TransactionType.Withdrawal 
                         && t.Status == TransactionStatus.Pending
                         && t.Amount == -request.Amount)
                .OrderByDescending(t => t.CreatedAt)
                .FirstOrDefaultAsync();

            if (pendingTransaction != null)
            {
                pendingTransaction.Status = TransactionStatus.Failed; 
                _unitOfWork.WalletTransactionRepository.Update(pendingTransaction);
            }

            var refundTransaction = new WalletTransaction
            {
                StoreId = store.Id,
                Amount = request.Amount,
                Type = TransactionType.WithdrawalRefund, 
                Status = TransactionStatus.Completed, 
                BalanceBefore = balanceBefore,
                BalanceAfter = store.WalletBalance,
                Description = $"Hoàn tiền lệnh rút #{requestId} bị từ chối. Lý do: {dto.AdminNote}"
            };
            request.Status = WithdrawalStatus.Rejected;
            request.AdminNote = dto.AdminNote;
            request.ProcessedByAdminId = adminId;
            request.ProcessedAt = DateTime.Now;

            await _unitOfWork.WalletTransactionRepository.AddAsync(refundTransaction);
            _unitOfWork.WithdrawalRequestRepository.Update(request);
            _unitOfWork.StoreRepository.Update(store);

            return await _unitOfWork.SaveChangesAsync() > 0;
        }

        public async Task<IEnumerable<WithdrawalRequestDto>> GetStoreRequestsAsync()
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();

            var requests = await _unitOfWork.WithdrawalRequestRepository
                .GetQueryable()
                .Include(r => r.Store)
                .Where(r => r.StoreId == storeId)
                .OrderByDescending(r => r.CreatedAt)
                .ToListAsync();

            return _mapper.Map<IEnumerable<WithdrawalRequestDto>>(requests);
        }

        public async Task<IEnumerable<WithdrawalRequestDto>> GetAllPendingRequestsAsync()
        {
            var requests = await _unitOfWork.WithdrawalRequestRepository
                .GetQueryable()
                .Include(r => r.Store)
                .Where(r => r.Status == WithdrawalStatus.Pending)
                .OrderBy(r => r.CreatedAt)
                .ToListAsync();

            return _mapper.Map<IEnumerable<WithdrawalRequestDto>>(requests);
        }

        private void ValidateStoreForWithdrawal(Store store, decimal amount)
        {
            if (amount < 100000) 
                throw new BadRequestException("Số tiền rút tối thiểu là 100,000đ.");
            
            if (store.WalletBalance < amount) 
                throw new BadRequestException("Số dư ví không đủ để thực hiện giao dịch.");
            
            if (string.IsNullOrEmpty(store.BankAccountNumber) || string.IsNullOrEmpty(store.BankName)) 
                throw new BadRequestException("Vui lòng cập nhật đầy đủ thông tin ngân hàng trước khi rút tiền.");
        }

        private void ValidatePendingRequest(WithdrawalRequest? request)
        {
            if (request == null) 
                throw new BadRequestException("Không tìm thấy yêu cầu rút tiền.");

            if (request.Status != WithdrawalStatus.Pending) 
                throw new BadRequestException("Yêu cầu không hợp lệ hoặc đã được xử lý.");
        }
    }
}