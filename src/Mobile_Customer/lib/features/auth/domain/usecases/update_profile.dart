import '../repositories/auth_repository.dart';

class UpdateProfile {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  Future<void> call(
    String fullName,
    String? email,
    String? avatarUrl,
  ) {
    return repository.updateProfile(fullName, email, avatarUrl);
  }
}