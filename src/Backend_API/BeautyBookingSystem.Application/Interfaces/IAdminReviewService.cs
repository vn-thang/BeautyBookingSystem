using BeautyBookingSystem.Application.DTOs.AdminReview;
using BeautyBookingSystem.Application.DTOs.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IAdminReviewService
    {
        Task<PagedResponse<ReviewDto>> GetReviewsAsync(ReviewFilterRequest request);
        Task<bool> ToggleReviewVisibilityAsync(int id, bool isHidden);
    }
}
