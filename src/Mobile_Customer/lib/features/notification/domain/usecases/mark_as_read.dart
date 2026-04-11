import '../repositories/notification_repository.dart';

class MarkAsRead {
  final NotificationRepository repository;

  MarkAsRead(this.repository);

  Future<bool> call(int id) {
    return repository.markAsRead(id);
  }
}