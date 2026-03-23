import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/update_profile_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> login(String email, String password) async {
    final loginResult = await remoteDataSource.login(email, password);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", loginResult.accessToken);
    await prefs.setString("refreshToken", loginResult.refreshToken);

    final profile = await remoteDataSource.getProfile();
    return profile;
  }

  @override
  Future<User> getProfile() async {
    final user = await remoteDataSource.getProfile();
    return user;
  }

  @override
  Future<User> register(
    String fullName,
    String phone,
    String email,
    String password,
  ) async {
    final result = await remoteDataSource.register(
      fullName,
      phone,
      email,
      password,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", result.accessToken);
    await prefs.setString("refreshToken", result.refreshToken);

    final profile = await remoteDataSource.getProfile();
    return profile;
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) {
    return remoteDataSource.changePassword(oldPassword, newPassword);
  }

  @override
  Future<void> forgotPassword(String email) {
    return remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> resetPassword(String email, String otp, String newPassword) {
    return remoteDataSource.resetPassword(email, otp, newPassword);
  }

  @override
  Future<void> updateProfile(
    String fullName,
    String? email,
    String? avatarUrl,
  ) async {
    final request = UpdateProfileRequestModel(
      fullName: fullName,
      email: email,
      avatarUrl: avatarUrl,
    );

    await remoteDataSource.updateProfile(request);
  }

  @override
  Future<void> uploadAvatar(XFile file) async {
    await remoteDataSource.uploadAvatar(file);
  }
}
