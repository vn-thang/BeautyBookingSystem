using AutoMapper;
using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.DTOs.AdminReview;
using BeautyBookingSystem.Application.DTOs.Common;
using BeautyBookingSystem.Application.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using AutoMapper.QueryableExtensions;


namespace BeautyBookingSystem.Application.Services
{
    public class AdminReviewService : IAdminReviewService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public AdminReviewService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<PagedResponse<ReviewDto>> GetReviewsAsync(ReviewFilterRequest request)
        {
            var query = _unitOfWork.ReviewRepository.GetQueryable();

            if (request.StoreId.HasValue)
                query = query.Where(r => r.StoreId == request.StoreId.Value);

            if (request.Rating.HasValue)
                query = query.Where(r => r.Rating == request.Rating.Value);

            if (request.IsHidden.HasValue)
                query = query.Where(r => r.IsHidden == request.IsHidden.Value);

            if (!string.IsNullOrWhiteSpace(request.SearchTerm))
            {
                string search = request.SearchTerm.ToLower();
                query = query.Where(r =>
                    (r.Comment != null && r.Comment.ToLower().Contains(search)) ||
                    (r.Customer.FullName.ToLower().Contains(search)) ||
                    (r.Store.Name.ToLower().Contains(search))
                );
            }

            int totalCount = await query.CountAsync();

            var reviews = await query
                .OrderByDescending(r => r.CreatedAt)
                .Skip((request.PageIndex - 1) * request.PageSize)
                .Take(request.PageSize)
                .ProjectTo<ReviewDto>(_mapper.ConfigurationProvider)
                .ToListAsync();

            return PagedResponse<ReviewDto>.Create(reviews, totalCount, request.PageIndex, request.PageSize);
        }

        public async Task<bool> ToggleReviewVisibilityAsync(int id, bool isHidden)
        {
            var review = await _unitOfWork.ReviewRepository.GetByIdAsync(id);
            if (review == null) throw new NotFoundException("Không tìm thấy đánh giá này.");

            if (review.IsHidden == isHidden) return true;

            review.IsHidden = isHidden;

            _unitOfWork.ReviewRepository.Update(review);
            return await _unitOfWork.SaveChangesAsync() > 0;
        }
    }
}
