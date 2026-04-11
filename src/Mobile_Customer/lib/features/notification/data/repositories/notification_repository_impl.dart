import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remote;

  NotificationRepositoryImpl(this.remote);

  @override
  Future<List<NotificationEntity>> getNotifications({int pageIndex = 1, int pageSize = 20}) {
    return remote.getNotifications(pageIndex, pageSize);
  }

  @override
  Future<int> getUnreadCount() {
    return remote.getUnreadCount();
  }

  @override
  Future<bool> markAsRead(int id) {
    return remote.markAsRead(id);
  }

  @override
  Future<bool> markAllAsRead() {
    return remote.markAllAsRead();
  }

  @override
  Future<bool> updateFcmToken(String fcmToken) {
    return remote.updateFcmToken(fcmToken);
  }
}