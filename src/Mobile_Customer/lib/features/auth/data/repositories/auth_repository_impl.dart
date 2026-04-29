import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/update_profile_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  String _mapErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? data['error'] ?? data['title'];
        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString().trim();
        }
      }

      if (data is String && data.trim().isNotEmpty) {
        return data.trim();
      }

      return error.message ?? 'Đã xảy ra lỗi';
    }

    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }

    return 'Đã xảy ra lỗi';
  }

  @override
  Future<User> login(String email, String password) async {
    try {
      final loginResult = await remoteDataSource.login(email, password);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", loginResult.accessToken);
      await prefs.setString("refreshToken", loginResult.refreshToken);

      return await remoteDataSource.getProfile();
    } catch (e) {
      throw Exception(_mapErrorMessage(e));
    }
  }

  @override
  Future<User> loginWithFirebase({
    required String idToken,
    String? fcmToken,
    bool linkToExistingAccount = false,
    bool isStoreOwnerApp = false,
  }) async {
    try {
      final result = await remoteDataSource.firebaseLogin(
        idToken: idToken,
        fcmToken: fcmToken,
        linkToExistingAccount: linkToExistingAccount,
        isStoreOwnerApp: isStoreOwnerApp,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", result.accessToken);
      await prefs.setString("refreshToken", result.refreshToken);

      return await remoteDataSource.getProfile();
    } catch (e) {
      throw Exception(_mapErrorMessage(e));
    }
  }

  @override
  Future<User> getProfile() async {
    try {
      return await remoteDataSource.getProfile();
    } catch (e) {
      throw Exception(_mapErrorMessage(e));
    }
  }

  @override
  Future<User> register(
    String fullName,
    String phone,
    String email,
    String password,
    String firebaseIdToken,
  ) async {
    try {
      final result = await remoteDataSource.register(
        fullName,
        phone,
        email,
        password,
        firebaseIdToken,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", result.accessToken);
      await prefs.setString("refreshToken", result.refreshToken);

      return await remoteDataSource.getProfile();
    } catch (e) {
      throw Exception(_mapErrorMessage(e));
    }
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await remoteDataSource.changePassword(oldPassword, newPassword);
    } catch (e) {
      throw Exception(_mapErrorMessage(e));
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await remoteDataSource.forgotPassword(email);
    } catch (e) {
      throw Exception(_mapErrorMessage(e));
    }
  }

  @override
  Future<void> verifyForgotPasswordOtp(String email, String otp) async {
    try {
      await remoteDataSource.verifyForgotPasswordOtp(email, otp);
    } catch (e) {
      throw Exception(_mapErrorMessage(e));
    }
  }

  @override
  Future<void> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      await remoteDataSource.resetPassword(email, otp, newPassword);
    } catch (e) {
      throw Exception(_mapErrorMessage(e));
    }
  }

  @override
  Future<void> updateProfile(
    String fullName,
    String? email,
    String? avatarUrl,
  ) async {
    try {
      final request = UpdateProfileRequestModel(
        fullName: fullName,
        email: email,
        avatarUrl: avatarUrl,
      );

      await remoteDataSource.updateProfile(request);
    } catch (e) {
      throw Exception(_mapErrorMessage(e));
    }
  }

  @override
  Future<void> uploadAvatar(XFile file) async {
    try {
      await remoteDataSource.uploadAvatar(file);
    } catch (e) {
      throw Exception(_mapErrorMessage(e));
    }
  }

  @override
  Future<void> verifyPhone(String firebaseIdToken) async {
    try {
      await remoteDataSource.verifyPhone(firebaseIdToken);
    } catch (e) {
      throw Exception(_mapErrorMessage(e));
    }
  }
}
