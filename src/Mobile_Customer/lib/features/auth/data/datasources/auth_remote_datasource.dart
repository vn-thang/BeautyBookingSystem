import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../models/login_response_model.dart';
import '../models/update_profile_request_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(String emailOrPhone, String password);
  Future<UserModel> getProfile();
  Future<LoginResponseModel> register(
    String fullName,
    String phone,
    String email,
    String password,
  );
  Future<LoginResponseModel> refreshToken(
    String accessToken,
    String refreshToken,
  );
  Future<void> changePassword(String oldPassword, String newPassword);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String email, String otp, String newPassword);
  Future<void> updateProfile(UpdateProfileRequestModel request);
  Future<void> uploadAvatar(XFile file);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<LoginResponseModel> login(String emailOrPhone, String password) async {
    final response = await dio.post('auth/login', data: {
      "emailOrPhone": emailOrPhone,
      "password": password,
    });

    if (response.data["success"] == false) {
      throw Exception(response.data["message"]);
    }

    return LoginResponseModel.fromJson(response.data["data"]);
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await dio.get('customer/customeruser/me');
      final data =
          response.data is Map<String, dynamic> && response.data['data'] != null
              ? response.data['data']
              : response.data;
      return UserModel.fromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      final message =
          e.response?.data?["message"] ?? "Không lấy được thông tin người dùng";
      throw Exception(message);
    }
  }

  @override
  Future<LoginResponseModel> register(
    String fullName,
    String phone,
    String email,
    String password,
  ) async {
    final response = await dio.post('auth/register', data: {
      "fullName": fullName,
      "phone": phone,
      "email": email,
      "password": password,
    });

    if (response.data["success"] == false) {
      throw Exception(response.data["message"]);
    }

    return LoginResponseModel.fromJson(response.data["data"]);
  }

  @override
  Future<LoginResponseModel> refreshToken(
    String accessToken,
    String refreshToken,
  ) async {
    final response = await dio.post('auth/refresh-token', data: {
      "accessToken": accessToken,
      "refreshToken": refreshToken,
    });

    if (response.data["success"] == false) {
      throw Exception(response.data["message"]);
    }

    return LoginResponseModel.fromJson(response.data["data"]);
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    await dio.put('auth/change-password', data: {
      "oldPassword": oldPassword,
      "newPassword": newPassword,
    });
  }

  @override
  Future<void> forgotPassword(String email) async {
    await dio.post('auth/forgot-password', data: {
      "email": email,
    });
  }

  @override
  Future<void> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    await dio.post('auth/reset-password', data: {
      "email": email,
      "otp": otp,
      "newPassword": newPassword,
    });
  }

  @override
  Future<void> updateProfile(UpdateProfileRequestModel request) async {
    await dio.put(
      'customer/customeruser/profile',
      data: request.toJson(),
    );
  }

  @override
  Future<void> uploadAvatar(XFile file) async {
    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
        filename: file.name,
      ),
    });

    await dio.post(
      'customer/customeruser/upload-avatar',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }
}
