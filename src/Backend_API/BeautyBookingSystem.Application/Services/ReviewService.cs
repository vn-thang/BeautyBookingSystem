using BeautyBookingSystem.Application.DTOs.Reviews;
using BeautyBookingSystem.Application.DTOs.User;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace BeautyBookingSystem.Application.Services
{
    public class ReviewService : IReviewService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly INotificationService _notificationService;

        public ReviewService(IUnitOfWork unitOfWork, INotificationService notificationService)
        {
            _unitOfWork = unitOfWork;
            _notificationService = notificationService;
        }

    public async Task<ReviewResponseDto> CreateAsync(int customerId, CreateReviewRequestDto request)
{
    if (request.Rating < 1 || request.Rating > 5)
        throw new InvalidOperationException("Rating phải từ 1 đến 5.");

    var booking = await _unitOfWork.BookingRepository.GetByIdWithDetailsAsync(request.BookingId);
    if (booking == null)
        throw new InvalidOperationException("Không tìm thấy booking.");

    if (booking.CustomerId != customerId)
        throw new UnauthorizedAccessException("Bạn không có quyền đánh giá booking này.");

    if (booking.Status != BookingStatus.Completed)
        throw new InvalidOperationException("Chỉ được đánh giá booking đã hoàn thành.");

    var existedReview = await _unitOfWork.ReviewRepository.GetByBookingIdAsync(request.BookingId);
    if (existedReview != null)
        throw new InvalidOperationException("Booking này đã được đánh giá trước đó.");

    var review = new Review
    {
        BookingId = booking.Id,
        CustomerId = customerId,
        StoreId = booking.StoreId,
        Rating = request.Rating,
        Comment = request.Comment,
        IsHidden = false
    };

    await _unitOfWork.ReviewRepository.AddAsync(review);
    await _unitOfWork.SaveChangesAsync();


            await RecalculateStoreRatingAsync(review.StoreId);
            await _unitOfWork.SaveChangesAsync();

    if (booking.Store != null)
    {
        try
        {
            string customerName = booking.Customer?.FullName ?? "Một khách hàng";
            string message = $"{customerName} vừa để lại đánh giá {request.Rating} sao cho đơn đặt lịch #{booking.Id}.";
            
            await _notificationService.CreateAndSendNotificationAsync(
                booking.Store.OwnerId,
                "⭐ Có đánh giá mới",
                message,
                NotificationType.SystemAlert
            );
        }
        catch (Exception ex)
        {
        }
    }

    // 6. Trả kết quả về cho Client
    return new ReviewResponseDto
    {
        Id = review.Id,
        BookingId = review.BookingId,
        CustomerId = review.CustomerId,
        StoreId = review.StoreId,
        StoreName = booking.Store?.Name ?? string.Empty,
        Rating = review.Rating,
        Comment = review.Comment,
        Reply = review.Reply,
        IsHidden = review.IsHidden,
        CreatedAt = review.CreatedAt
    };
}
        public async Task<List<ReviewResponseDto>> GetMyReviewsAsync(int customerId)
        {
            var reviews = await _unitOfWork.ReviewRepository.GetByCustomerIdAsync(customerId);

            return reviews.Select(r => new ReviewResponseDto
            {
                Id = r.Id,
                BookingId = r.BookingId,
                CustomerId = r.CustomerId,
                StoreId = r.StoreId,
                StoreName = r.Store?.Name ?? string.Empty,
                Rating = r.Rating,
                Comment = r.Comment,
                Reply = r.Reply,
                IsHidden = r.IsHidden,
                CreatedAt = r.CreatedAt
            }).ToList();
        }


        public async Task<List<StoreReviewResponseDto>> GetTopByStoreIdAsync(int storeId, int take = 5)
        {
            var reviews = await _unitOfWork.ReviewRepository.GetTopByStoreIdAsync(storeId, take);
            return reviews.Select(MapToStoreReviewDto).ToList();
        }

        public async Task<List<StoreReviewResponseDto>> GetPagedByStoreIdAsync(
            int storeId,
            int page,
            int pageSize,
            int? rating = null,
            string sortBy = "latest")
        {
            if (page < 1) page = 1;
            if (pageSize < 1) pageSize = 10;

            var skip = (page - 1) * pageSize;

            var reviews = await _unitOfWork.ReviewRepository.GetPagedByStoreIdAsync(
                storeId,
                rating,
                sortBy,
                skip,
                pageSize);

            return reviews.Select(MapToStoreReviewDto).ToList();
        }

        public async Task<int> CountByStoreIdAsync(int storeId, int? rating = null)
        {
            return await _unitOfWork.ReviewRepository.CountByStoreIdAsync(storeId, rating);
        }

        private async Task RecalculateStoreRatingAsync(int storeId)
        {
            var stats = await _unitOfWork.ReviewRepository
                .GetQueryable()
                .Where(r => r.StoreId == storeId && !r.IsHidden)
                .GroupBy(r => r.StoreId)
                .Select(g => new
                {
                    TotalReviews = g.Count(),
                    AverageRating = g.Average(x => (decimal)x.Rating)
                })
                .FirstOrDefaultAsync();

            var store = await _unitOfWork.StoreRepository
                .GetQueryable()
                .FirstOrDefaultAsync(s => s.Id == storeId);

            if (store == null)
                throw new InvalidOperationException("Không tìm thấy cửa hàng.");

            store.TotalReviews = stats?.TotalReviews ?? 0;
            store.AverageRating = stats?.AverageRating ?? 0;

            _unitOfWork.StoreRepository.Update(store);
        }

        private static StoreReviewResponseDto MapToStoreReviewDto(Review r)
        {
            return new StoreReviewResponseDto
            {
                Id = r.Id,
                BookingId = r.BookingId,
                CustomerId = r.CustomerId,
                StoreId = r.StoreId,
                StoreName = r.Store?.Name ?? string.Empty,
                Customer = new UserProfileResponse
                {
                    Id = r.Customer?.Id ?? 0,
                    FullName = r.Customer?.FullName ?? string.Empty,
                    AvatarUrl = r.Customer?.AvatarUrl,
                    CreatedAt = r.Customer?.CreatedAt ?? DateTime.MinValue
                },
                Rating = r.Rating,
                Comment = r.Comment,
                Reply = r.Reply,
                IsHidden = r.IsHidden,
                CreatedAt = r.CreatedAt
            };
        }
    }
}