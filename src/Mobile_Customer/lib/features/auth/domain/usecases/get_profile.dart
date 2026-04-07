
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetProfile {
  final AuthRepository repository;
  GetProfile(this.repository);
  Future<User> call() async {
    return await repository.getProfile();
  }
}