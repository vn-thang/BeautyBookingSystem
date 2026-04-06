using BeautyBookingSystem.Application.DTOs.Common;
using BeautyBookingSystem.Application.DTOs.AdminWallet;
using BeautyBookingSystem.Domain.Enums;
using BeautyBookingSystem.Application.DTOs.StoreWallet;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IAdminWalletService
    {
        Task<PagedResponse<AdminWalletTransactionDto>> GetAllTransactionsAsync(
            int pageIndex, 
            int pageSize, 
            DateTime? startDate = null, 
            DateTime? endDate = null, 
            string? storeName = null, 
            TransactionType? type = null);
            Task<bool> AdjustStoreWalletBalanceAsync(int storeId, AdjustWalletRequest request);
            Task<PagedResponse<WithdrawalRequestDto>> GetPendingWithdrawalsAsync(int pageIndex, int pageSize, string? storeName = null);
            Task<PagedResponse<WithdrawalRequestDto>> GetProcessedWithdrawalsAsync(int pageIndex, int pageSize, string? storeName = null);
           Task<bool> ApproveWithdrawalAsync(int transactionId, ApproveWithdrawalDto request);
            Task<bool> RejectWithdrawalAsync(int transactionId, RejectWithdrawalDto request);
    }
}