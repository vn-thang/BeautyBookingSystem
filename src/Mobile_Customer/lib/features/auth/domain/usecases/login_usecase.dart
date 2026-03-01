import '../repositories/auth_repository.dart';
import '../entities/user_entity.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<(String token, UserEntity user)> call({
    required String phone,
    required String password,
  }) {
    return repository.login(phone: phone, password: password);
  }
}