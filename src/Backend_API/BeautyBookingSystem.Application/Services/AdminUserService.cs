using AutoMapper;
using AutoMapper.QueryableExtensions;
using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.DTOs.AdminUser;
using BeautyBookingSystem.Application.DTOs.Common;
using BeautyBookingSystem.Application.Interfaces;
using BeautyBookingSystem.Domain.Enums;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Services
{
    public class AdminUserService : IAdminUserService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly ICurrentUserService _currentUserService;
        private readonly INotificationService _notificationService;

        public AdminUserService(
            IUnitOfWork unitOfWork,
            IMapper mapper,
            ICurrentUserService currentUserService,
            INotificationService notificationService)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _currentUserService = currentUserService;
            _notificationService = notificationService;
        }

        public async Task<PagedResponse<UserDto>> GetUsersAsync(UserFilterRequest request)
        {
           var query = _unitOfWork.UserRepository.GetQueryable();

            if (!string.IsNullOrWhiteSpace(request.SearchTerm))
            {
                string search = request.SearchTerm.Trim().ToLower();

                query = query.Where(u => 
                    (u.FullName != null && u.FullName!.ToLower().Contains(search)) ||
                    (u.Phone != null && u.Phone!.Contains(search)) ||
                    (u.Email != null && u.Email!.ToLower().Contains(search))
                );
            }

            if (request.Role.HasValue)
                query = query.Where(u => u.Role == request.Role.Value);

            if (request.Status.HasValue)
                query = query.Where(u => u.Status == request.Status.Value);

            int totalCount = await query.CountAsync();

            var users = await query
                .OrderByDescending(u => u.CreatedAt)
                .Skip((request.PageIndex - 1) * request.PageSize)
                .Take(request.PageSize)
                .ProjectTo<UserDto>(_mapper.ConfigurationProvider)
                .ToListAsync();
            return PagedResponse<UserDto>.Create(users, totalCount, request.PageIndex, request.PageSize);
        }

        public async Task<UserDetailDto?> GetUserByIdAsync(int id)
        {
            return await _unitOfWork.UserRepository.GetQueryable()
                .Where(u => u.Id == id)
                .ProjectTo<UserDetailDto>(_mapper.ConfigurationProvider)
                .FirstOrDefaultAsync();
        }

        public async Task<bool> ChangeUserStatusAsync(int id, UpdateUserStatusRequest request)
        {
            int currentAdminId = _currentUserService.GetUserId();

            if (id == currentAdminId)
            {
                throw new ForbiddenException("You cannot deactivate your own admin account.");
            }

            var user = await _unitOfWork.UserRepository.GetByIdAsync(id);
            if (user == null) return false;

            user.Status = request.NewStatus;

            _unitOfWork.UserRepository.Update(user);
            var result = await _unitOfWork.SaveChangesAsync() > 0;

            if (result)
            {
                string title = "Cập nhật trạng thái tài khoản";
                string message = request.NewStatus == UserStatus.Active 
                    ? "Tài khoản của bạn đã được kích hoạt và có thể hoạt động bình thường."
                    : "⚠️ Tài khoản của bạn đã bị khóa hoặc vô hiệu hóa bởi Quản trị viên. Vui lòng liên hệ CSKH nếu có thắc mắc.";

                _ = _notificationService.CreateAndSendNotificationAsync(
                    user.Id,
                    title,
                    message,
                    NotificationType.SystemAlert
                );
            }
            return result;
        }
    }
}
