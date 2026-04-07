using AutoMapper;
using BeautyBookingSystem.Application.Common.Exceptions;
using BeautyBookingSystem.Application.DTOs.Notification;
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
    public class NotificationService : INotificationService
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly ICurrentUserService _currentUserService;
        private readonly IMapper _mapper;
        private readonly IFirebasePushNotificationService _firebaseService;

        public NotificationService(
            IUnitOfWork unitOfWork,
            ICurrentUserService currentUserService,
            IMapper mapper,
            IFirebasePushNotificationService firebaseService)
        {
            _unitOfWork = unitOfWork;
            _currentUserService = currentUserService;
            _mapper = mapper;
            _firebaseService = firebaseService;
        }

        public async Task<bool> UpdateFcmTokenAsync(string fcmToken)
        {
            int userId = _currentUserService.GetUserId(); 
            var user = await _unitOfWork.UserRepository.GetByIdAsync(userId);
            if (user == null) return false;

            user.FcmToken = fcmToken;
            _unitOfWork.UserRepository.Update(user);
            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task<List<NotificationDto>> GetNotificationsAsync(int pageIndex = 1, int pageSize = 20)
        {
            int userId = _currentUserService.GetUserId();
            var notifications = await _unitOfWork.NotificationRepository.GetQueryable()
                .Where(n => n.UserId == userId)
                .OrderByDescending(n => n.CreatedAt) 
                .Skip((pageIndex - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return _mapper.Map<List<NotificationDto>>(notifications);
        }

        public async Task<int> GetUnreadCountAsync()
        {
            int userId = _currentUserService.GetUserId();
            return await _unitOfWork.NotificationRepository.GetQueryable()
                .CountAsync(n => n.UserId == userId && !n.IsRead);
        }

        public async Task<bool> MarkAsReadAsync(int id)
        {
            int userId = _currentUserService.GetUserId();
            var notification = await _unitOfWork.NotificationRepository.GetQueryable()
                .FirstOrDefaultAsync(n => n.Id == id && n.UserId == userId);

            if (notification == null) return false;

            notification.IsRead = true;
            _unitOfWork.NotificationRepository.Update(notification);
            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task<bool> MarkAllAsReadAsync()
        {
            int userId = _currentUserService.GetUserId();
            var unreads = await _unitOfWork.NotificationRepository.GetQueryable()
                .Where(n => n.UserId == userId && !n.IsRead)
                .ToListAsync();

            foreach (var n in unreads)
            {
                n.IsRead = true;
                _unitOfWork.NotificationRepository.Update(n);
            }
            await _unitOfWork.SaveChangesAsync();
            return true;
        }

        public async Task CreateAndSendNotificationAsync(int userId, string title, string message, NotificationType type)
        {
            var notification = new Notification 
            {
                UserId = userId,
                Title = title,
                Message = message,
                Type = type,
                IsRead = false,
            };

            await _unitOfWork.NotificationRepository.AddAsync(notification);
            await _unitOfWork.SaveChangesAsync();

            var user = await _unitOfWork.UserRepository.GetByIdAsync(userId);
            if (user != null && !string.IsNullOrEmpty(user.FcmToken))
            {
  
                _ = _firebaseService.SendPushNotificationAsync(user.FcmToken, title, message);
            }
        }
    }
}
