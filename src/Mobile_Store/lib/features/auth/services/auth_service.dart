import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../core/network/api_client.dart';
import '../models/login_response_model.dart';
import '../models/register_response_model.dart';
import '../../../shared/token_storage.dart';

class AuthService {
  static String _extractError(dynamic e) {
    return e.toString().replaceAll('Exception: ', '');
  }

  static Future<AuthResult<LoginResponseModel>> login(String emailOrPhone, String password) async {
    try {
      String? fcmToken;
      try { fcmToken = await FirebaseMessaging.instance.getToken(); } catch (_) {}

      final json = await ApiClient.post('/api/Auth/login', body: {
        'emailOrPhone': emailOrPhone, 'password': password, 'fcmToken': fcmToken,
      });

      final data = json['data'] ?? json; 
      final accessToken = data['accessToken'];
      final refreshToken = data['refreshToken'];

      await TokenStorage.saveTokens(accessToken, refreshToken);
      try {
        Map<String, dynamic> decoded = JwtDecoder.decode(accessToken);
       
        var rawStoreId = decoded['storeId'] ?? decoded['StoreId'];
       if (rawStoreId != null) {
          int sid = int.parse(rawStoreId.toString());
         
          await TokenStorage.saveStoreId(sid);
        }

        var rawUserId = decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ?? decoded['Id'] ?? decoded['id'] ?? decoded['sub'];
        if (rawUserId != null) {
        }

        await TokenStorage.saveTokens(accessToken, refreshToken);
      } catch (e) {
        debugPrint('Lỗi giải mã JWT: $e');
      }

      return AuthResult.success(LoginResponseModel(
        accessToken: accessToken,
        refreshToken: data['refreshToken'],
        role: data['role'] ?? '',
        storeStatus: data['storeStatus'],
      ));
    } catch (e) {
      return AuthResult.failure(_extractError(e));
    }
  }

  static Future<AuthResult<RegisterResponseModel>> registerPartner(String ownerName, String phone, String email, String password) async {
    try {
      final json = await ApiClient.post('/api/Auth/register-partner', body: {
        'fullName': ownerName, 'phone': phone, 'email': email, 'password': password
      });
      return AuthResult.success(RegisterResponseModel.fromJson(json));
    } catch (e) {
      return AuthResult.failure(_extractError(e));
    }
  }

  static Future<AuthResult<bool>> forgotPassword(String email) async {
    try {
      await ApiClient.post('/api/Auth/forgot-password', body: {'email': email});
      return AuthResult.success(true);
    } catch (e) {
      return AuthResult.failure(_extractError(e));
    }
  }

  static Future<AuthResult<bool>> resetPassword(String email, String otp, String newPassword) async {
    try {
      await ApiClient.post('/api/Auth/reset-password', body: {
        'email': email, 'otp': otp, 'newPassword': newPassword
      });
      return AuthResult.success(true);
    } catch (e) {
      return AuthResult.failure(_extractError(e));
    }
  }

  static Future<AuthResult<String>> logout() async {
    try {
      await ApiClient.post('/api/Auth/logout'); 
      await TokenStorage.clearTokens();
      return AuthResult.success('Đăng xuất thành công');
    } catch (e) {
      await TokenStorage.clearTokens(); 
      return AuthResult.success('Đăng xuất ngoại tuyến');
    }
  }
}

class AuthResult<T> {
  final bool isSuccess;
  final T? data;
  final String? errorMessage;

  AuthResult.success(this.data) : isSuccess = true, errorMessage = null;
  AuthResult.failure(this.errorMessage) : isSuccess = false, data = null;
}