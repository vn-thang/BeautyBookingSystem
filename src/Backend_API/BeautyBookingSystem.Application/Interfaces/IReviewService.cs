using BeautyBookingSystem.Application.DTOs.Reviews;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IReviewService
    {
        Task<ReviewResponseDto> CreateAsync(int customerId, CreateReviewRequestDto request);
        Task<List<ReviewResponseDto>> GetMyReviewsAsync(int customerId);
        Task ReplyAsync(int reviewId, string reply);
        Task<List<StoreReviewResponseDto>> GetTopByStoreIdAsync(int storeId, int take = 5);

        Task<List<StoreReviewResponseDto>> GetPagedByStoreIdAsync(
            int storeId,
            int page,
            int pageSize,
            int? rating = null,
            string sortBy = "latest");

        Task<int> CountByStoreIdAsync(int storeId, int? rating = null);
    }
}