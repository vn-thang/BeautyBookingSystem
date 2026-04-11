import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications({int pageIndex = 1, int pageSize = 20});
  Future<int> getUnreadCount();
  Future<bool> markAsRead(int id);
  Future<bool> markAllAsRead();
  Future<bool> updateFcmToken(String fcmToken);
}