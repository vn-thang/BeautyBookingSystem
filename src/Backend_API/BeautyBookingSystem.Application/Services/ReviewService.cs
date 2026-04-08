using BeautyBookingSystem.Application.DTOs.Reviews;
using BeautyBookingSystem.Application.DTOs.User;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Services
{
    public class ReviewService : IReviewService
    {
        private readonly IUnitOfWork _unitOfWork;

        public ReviewService(IUnitOfWork unitOfWork)
        {
            _unitOfWork = unitOfWork;
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

        public async Task ReplyAsync(int reviewId, string reply)
        {
            var review = await _unitOfWork.ReviewRepository.GetByIdAsync(reviewId);
            if (review == null)
                throw new InvalidOperationException("Không tìm thấy review.");

            review.Reply = reply;
            _unitOfWork.ReviewRepository.Update(review);
            await _unitOfWork.SaveChangesAsync();
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
        public async Task<List<StoreReviewResponseDto>> GetTopByStoreIdAsync(int storeId, int take = 5)
        {
            var reviews = await _unitOfWork.ReviewRepository.GetByStoreIdAsync(storeId);

            return reviews
                .Take(take)
                .Select(MapToStoreReviewDto)
                .ToList();
        }
        public async Task<List<StoreReviewResponseDto>> GetPagedByStoreIdAsync(int storeId, int page, int pageSize)
        {
            if (page < 1) page = 1;
            if (pageSize < 1) pageSize = 10;

            var skip = (page - 1) * pageSize;

            var reviews = await _unitOfWork.ReviewRepository.GetPagedByStoreIdAsync(storeId, skip, pageSize);

            return reviews
                .Select(MapToStoreReviewDto)
                .ToList();
        }
        public async Task<int> CountByStoreIdAsync(int storeId)
        {
            return await _unitOfWork.ReviewRepository.CountByStoreIdAsync(storeId);
        }
    }
}
