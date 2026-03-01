import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<(String token, UserEntity user)> login({
    required String phone,
    required String password,
  });
}