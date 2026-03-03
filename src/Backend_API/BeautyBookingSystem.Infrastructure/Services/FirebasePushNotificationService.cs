using BeautyBookingSystem.Application.Interfaces;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Infrastructure.Services
{
    public class FirebasePushNotificationService : IFirebasePushNotificationService
    {
        private readonly ILogger<FirebasePushNotificationService> _logger;

        public FirebasePushNotificationService(ILogger<FirebasePushNotificationService> logger)
        {
            _logger = logger;
        }

        public Task SendPushNotificationAsync(string fcmToken, string title, string body)
        {
            _logger.LogInformation($"[MOCK FIREBASE PUSH] Gửi tới Token: {fcmToken} | Title: {title} | Body: {body}");

            return Task.CompletedTask;
        }
    }
}
