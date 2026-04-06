using BeautyBookingSystem.Application.DTOs.StoreWallet;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IWithdrawalService
    {
       Task<bool> CreateRequestAsync(CreateWithdrawalDto dto);
        Task<bool> ApproveRequestAsync(int requestId, ApproveWithdrawalDto dto);
        Task<bool> RejectRequestAsync(int requestId, RejectWithdrawalDto dto);
        Task<IEnumerable<WithdrawalRequestDto>> GetStoreRequestsAsync();
        Task<IEnumerable<WithdrawalRequestDto>> GetAllPendingRequestsAsync();
        
    }
}