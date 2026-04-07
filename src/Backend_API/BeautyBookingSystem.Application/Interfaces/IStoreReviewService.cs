using BeautyBookingSystem.Application.DTOs.StoreReview;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IStoreReviewService
    {
        Task<List<StoreReviewDto>> GetReviewsAsync(StoreReviewFilterRequest request);
        Task<StoreReviewDto> GetReviewByIdAsync(int id);
        Task<bool> ReplyReviewAsync(int id, ReplyReviewRequest request);
    }
}
