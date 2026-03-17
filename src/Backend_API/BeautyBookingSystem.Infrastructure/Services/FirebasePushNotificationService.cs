using BeautyBookingSystem.Application.Interfaces;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using FirebaseAdmin.Messaging;

namespace BeautyBookingSystem.Infrastructure.Services
{
    public class FirebasePushNotificationService : IFirebasePushNotificationService
    {
        private readonly ILogger<FirebasePushNotificationService> _logger;

        public FirebasePushNotificationService(ILogger<FirebasePushNotificationService> logger)
        {
            _logger = logger;
        }

        public async Task SendPushNotificationAsync(string fcmToken, string title, string body)
        {
            if (string.IsNullOrWhiteSpace(fcmToken))
            {
                _logger.LogWarning("Không thể gửi thông báo vì FcmToken bị rỗng.");
                return;
            }

            try
            {
                // 1. Tạo gói tin Notification
                var message = new Message()
                {
                    Token = fcmToken,
                    Notification = new Notification()
                    {
                        Title = title,
                        Body = body
                    }
                };

                // 2. Ra lệnh cho Firebase gửi đi
                string response = await FirebaseMessaging.DefaultInstance.SendAsync(message);

                _logger.LogInformation($"[THÀNH CÔNG] Đã gửi thông báo tới {fcmToken}. Firebase Response: {response}");
            }
            catch (Exception ex)
            {
                _logger.LogError($"[THẤT BẠI] Lỗi khi gửi Firebase Push Notification: {ex.Message}");
            }
        }
    }
}
