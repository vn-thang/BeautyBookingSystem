// features/notification/domain/usecases/update_fcm_token.dart
import '../repositories/notification_repository.dart';

class UpdateFcmToken {
  final NotificationRepository repository;

  UpdateFcmToken(this.repository);

  Future<bool> call(String fcmToken) {
    return repository.updateFcmToken(fcmToken);
  }
}
