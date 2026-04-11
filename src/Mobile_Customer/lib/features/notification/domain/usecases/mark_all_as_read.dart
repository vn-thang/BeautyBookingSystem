import '../repositories/notification_repository.dart';

class MarkAllAsRead {
  final NotificationRepository repository;

  MarkAllAsRead(this.repository);

  Future<bool> call() {
    return repository.markAllAsRead();
  }
}