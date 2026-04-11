using BeautyBookingSystem.Application.DTOs.Common;
using BeautyBookingSystem.Application.DTOs.StoreWallet;
using BeautyBookingSystem.Domain.Enums;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IStoreWalletService
    {
        Task<decimal> ProcessBookingCommissionAsync(int bookingId);
        Task<bool> TopUpWalletAsync(int storeId, decimal amount, string note);
        Task<PagedResponse<WalletTransactionDto>> GetTransactionHistoryAsync(int pageIndex, int pageSize, int? month = null, int? year = null, TransactionType? type = null);
        Task<int> ProcessMonthlyAppFeeAsync();
        Task<WalletDashboardDto> GetWalletDashboardAsync(int? month = null, int? year = null);
        Task<WalletBalanceDto> GetWalletBalanceAsync();
        Task<string> CreateVnPayTopUpUrlAsync(TopUpRequest request);
        Task<string> ProcessVnPayCallbackAsync();
        Task ReceiveDepositAsync(int bookingId);  
        Task ClawbackDepositAsync(int bookingId);
        Task<decimal> ProcessBookingPenaltyAsync(int bookingId);
    }
}