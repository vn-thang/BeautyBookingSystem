using BeautyBookingSystem.Application.DTOs.Notification;
using BeautyBookingSystem.Domain.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface INotificationService
    {
        Task<bool> UpdateFcmTokenAsync(string fcmToken);
        Task<List<NotificationDto>> GetNotificationsAsync(int pageIndex = 1, int pageSize = 20);
        Task<int> GetUnreadCountAsync();
        Task<bool> MarkAsReadAsync(int id);
        Task<bool> MarkAllAsReadAsync();
        Task CreateAndSendNotificationAsync(int userId, string title, string message, NotificationType type);
        Task SendBookingReminderAsync(int bookingId);
    }
}
