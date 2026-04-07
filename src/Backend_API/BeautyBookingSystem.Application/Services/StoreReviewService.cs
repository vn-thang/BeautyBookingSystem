using AutoMapper;
using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.DTOs.StoreReview;
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
    public class StoreReviewService : IStoreReviewService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUserService _currentUserService;
        private readonly IMapper _mapper;
        private readonly INotificationService _notificationService;

        public StoreReviewService(IUnitOfWork unitOfWork, ICurrentUserService currentUserService, IMapper mapper, INotificationService notificationService)
        {
            _unitOfWork = unitOfWork;
            _currentUserService = currentUserService;
            _mapper = mapper;
            _notificationService = notificationService;
        }

        private async Task<Review> GetAndValidateOwnershipAsync(int reviewId, int storeId)
        {
            var review = await _unitOfWork.ReviewRepository.GetQueryable()
                .Include(r => r.Customer)
                .FirstOrDefaultAsync(r => r.Id == reviewId);

            if (review == null || review.StoreId != storeId)
                throw new NotFoundException("Đánh giá không tồn tại hoặc không thuộc về cửa hàng của bạn!");

            return review;
        }

        public async Task<List<StoreReviewDto>> GetReviewsAsync(StoreReviewFilterRequest request)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();

            var query = _unitOfWork.ReviewRepository.GetQueryable()
                .Include(r => r.Customer)
                .Where(r => r.StoreId == storeId);

            if (request.Rating.HasValue)
                query = query.Where(r => r.Rating == request.Rating.Value);

            if (request.HasReplied.HasValue)
            {
                if (request.HasReplied.Value)
                    query = query.Where(r => r.Reply != null && r.Reply != "");
                else
                    query = query.Where(r => r.Reply == null || r.Reply == "");
            }

            var reviews = await query.OrderByDescending(r => r.CreatedAt).ToListAsync();

            return _mapper.Map<List<StoreReviewDto>>(reviews);
        }

        public async Task<StoreReviewDto> GetReviewByIdAsync(int id)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();
            var review = await GetAndValidateOwnershipAsync(id, storeId);

            return _mapper.Map<StoreReviewDto>(review);
        }

        public async Task<bool> ReplyReviewAsync(int id, ReplyReviewRequest request)
        {
            int storeId = await _currentUserService.GetCurrentStoreIdAsync();
            var review = await _unitOfWork.ReviewRepository.GetQueryable()
                .Include(r => r.Store)
                .FirstOrDefaultAsync(r => r.Id == id && r.StoreId == storeId);

            if (review == null)
                throw new NotFoundException("Đánh giá không tồn tại hoặc không thuộc về cửa hàng của bạn!");

            review.Reply = request.Reply;

            _unitOfWork.ReviewRepository.Update(review);
            var result = await _unitOfWork.SaveChangesAsync() > 0;

            if (result)
            {
                _ = _notificationService.CreateAndSendNotificationAsync(
                    review.CustomerId,
                    "💬Phản hồi mới từ cửa hàng",
                    $"{review.Store!.Name} đã phản hồi đánh giá của bạn: \"{request.Reply}\"",
                    NotificationType.SystemAlert
                );
            }

            return result;
        }
    }
    }
