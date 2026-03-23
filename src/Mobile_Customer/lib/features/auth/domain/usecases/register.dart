import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class Register {
  final AuthRepository repository;

  Register(this.repository);

  Future<User> call(
    String fullName,
    String phone,
    String email,
    String password,
  ) {
    return repository.register(
      fullName,
      phone,
      email,
      password,
    );
  }
}