using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BeautyBookingSystem.Application.Interfaces
{
    public interface IFirebasePushNotificationService
    {
        Task SendPushNotificationAsync(string fcmToken, string title, string body);
    }
}
