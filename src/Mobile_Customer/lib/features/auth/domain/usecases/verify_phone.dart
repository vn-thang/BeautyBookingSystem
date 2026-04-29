import '../repositories/auth_repository.dart';

class VerifyPhone {
  final AuthRepository repository;

  VerifyPhone(this.repository);

  Future<void> call(String firebaseIdToken) {
    return repository.verifyPhone(firebaseIdToken);
  }
}
