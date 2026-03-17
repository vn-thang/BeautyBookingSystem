import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/network/api_client.dart';
import '../models/user_profile_model.dart';

class AccountResult<T> {
  final bool isSuccess;
  final T? data;
  final String? errorMessage;

  AccountResult.success(this.data) : isSuccess = true, errorMessage = null;
  AccountResult.failure(this.errorMessage) : isSuccess = false, data = null;
}

class AccountService {
  static String _extractError(dynamic e) {
    return e.toString().replaceAll('Exception: ', '');
  }

  // 1. Lấy thông tin Profile
  static Future<AccountResult<UserProfileModel>> getProfile() async {
    try {
      final json = await ApiClient.get('/api/User/me');
      final data = json['data'] ?? json;
      return AccountResult.success(UserProfileModel.fromJson(data));
    } catch (e) {
      return AccountResult.failure(_extractError(e));
    }
  }

  // 2. Cập nhật Profile
  static Future<AccountResult<bool>> updateProfile({
    required String fullName,
    String? email,
    String? avatarUrl,
  }) async {
    try {
      String? fcmToken;
      try { fcmToken = await FirebaseMessaging.instance.getToken(); } catch (_) {}

      await ApiClient.put('/api/User/profile', body: {
        'fullName': fullName,
        'email': email,
        'avatarUrl': avatarUrl,
        'fcmToken': fcmToken,
      });
      return AccountResult.success(true);
    } catch (e) {
      return AccountResult.failure(_extractError(e));
    }
  }

  // 3. Đổi mật khẩu
  static Future<AccountResult<bool>> changePassword(String oldPassword, String newPassword) async {
    try {
      await ApiClient.put('/api/Auth/change-password', body: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
      return AccountResult.success(true);
    } catch (e) {
      return AccountResult.failure(_extractError(e));
    }
  }
}