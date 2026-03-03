using AutoMapper;
using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.DTOs.User;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Services
{
    public class UserService : IUserService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;

        public UserService(IUnitOfWork unitOfWork, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
        }

        public async Task<UserProfileResponse> GetProfileAsync(string userId)
        {
            var user = await GetUserOrThrowAsync(userId);
            return _mapper.Map<UserProfileResponse>(user);
        }

        public async Task<bool> UpdateProfileAsync(string userId, UpdateProfileRequest request)
        {
            var user = await GetUserOrThrowAsync(userId);

            if (!string.IsNullOrWhiteSpace(request.Email) && request.Email != user.Email)
            {
                var emailInUse = await _unitOfWork.UserRepository
                    .GetQueryable()
                    .AnyAsync(u => u.Email == request.Email);

                if (emailInUse) throw new BadRequestException("Email này đã được sử dụng!");
            }

            _mapper.Map(request, user);

            user.UpdatedAt = DateTime.UtcNow;

            _unitOfWork.UserRepository.Update(user);
            await _unitOfWork.SaveChangesAsync();

            return true;
        }
        private async Task<User> GetUserOrThrowAsync(string userId)
        {
            if (!int.TryParse(userId, out int parsedUserId))
                throw new BadRequestException("Định dạng ID người dùng không hợp lệ!");

            var user = await _unitOfWork.UserRepository.GetByIdAsync(parsedUserId);
            if (user == null)
                throw new NotFoundException("Người dùng không tồn tại!");

            return user;
        }
    }
}
