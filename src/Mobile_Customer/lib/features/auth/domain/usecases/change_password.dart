import '../repositories/auth_repository.dart';

class ChangePassword {
  final AuthRepository repository;

  ChangePassword(this.repository);

  Future<void> call(String oldPassword, String newPassword) {
    return repository.changePassword(oldPassword, newPassword);
  }
}