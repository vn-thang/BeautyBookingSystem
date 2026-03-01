import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<(String token, UserEntity user)> login({
    required String phone,
    required String password,
  }) async {
    final result = await remoteDataSource.login(
      phone: phone,
      password: password,
    );

    return (result.$1, result.$2.toEntity());
  }
}