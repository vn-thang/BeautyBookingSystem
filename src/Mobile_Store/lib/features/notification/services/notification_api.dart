import '../../../core/network/api_client.dart';
import '../models/notification_model.dart'; 

class NotificationApi {

  static Future<bool> updateFcmToken(String fcmToken) async {
    await ApiClient.put('/api/Notifications/fcm-token', body: {'fcmToken': fcmToken});
    return true;
  }

  static Future<List<NotificationModel>> getNotifications({int pageIndex = 1, int pageSize = 20}) async {
    final json = await ApiClient.get('/api/Notifications?pageIndex=$pageIndex&pageSize=$pageSize');
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  static Future<int> getUnreadCount() async {
    final json = await ApiClient.get('/api/Notifications/unread-count');
    return json['count'] ?? 0;
  }

  static Future<bool> markAsRead(int id) async {
    await ApiClient.put('/api/Notifications/$id/read');
    return true;
  }

  static Future<bool> markAllAsRead() async {
    await ApiClient.put('/api/Notifications/read-all');
    return true;
  }
}