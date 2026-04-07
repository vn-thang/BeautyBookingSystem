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
    try {
      final response = await dio.post('/auth/login', data: {
        "emailOrPhone": emailOrPhone,
        "password": password,
      });

      if (response.data["success"] == false) {
        throw Exception(response.data["message"]);
      }

      final data = response.data["data"];
      return LoginResponseModel.fromJson(data);
    } on DioException catch (e) {
      String message = "Đăng nhập thất bại";

      if (e.response != null) {
        final data = e.response?.data;

        if (data is Map && data["message"] != null) {
          message = data["message"];
        } else if (data is String) {
          message = data;
        }
      }

      throw Exception(message);
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await dio.get('/user/me');
      return UserModel.fromJson(response.data);
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
    try {
      final response = await dio.post('/auth/register', data: {
        "fullName": fullName,
        "phone": phone,
        "email": email,
        "password": password,
      });

      if (response.data["success"] == false) {
        throw Exception(response.data["message"]);
      }

      final data = response.data["data"];
      return LoginResponseModel.fromJson(data);
    } on DioException catch (e) {
      String message = "Đăng ký thất bại";

      if (e.response != null) {
        final data = e.response?.data;

        if (data is Map && data["message"] != null) {
          message = data["message"];
        } else if (data is String) {
          message = data;
        }
      }

      throw Exception(message);
    }
  }

  @override
  Future<LoginResponseModel> refreshToken(
    String accessToken,
    String refreshToken,
  ) async {
    try {
      final response = await dio.post('/auth/refresh-token', data: {
        "accessToken": accessToken,
        "refreshToken": refreshToken,
      });

      if (response.data["success"] == false) {
        throw Exception(response.data["message"]);
      }

      final data = response.data["data"];
      return LoginResponseModel.fromJson(data);
    } on DioException catch (e) {
      String message = "Refresh token thất bại";

      if (e.response != null) {
        final data = e.response?.data;

        if (data is Map && data["message"] != null) {
          message = data["message"];
        } else if (data is String) {
          message = data;
        }
      }

      throw Exception(message);
    }
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await dio.put('/auth/change-password', data: {
        "oldPassword": oldPassword,
        "newPassword": newPassword,
      });
    } on DioException catch (e) {
      final message = e.response?.data?["message"] ?? "Đổi mật khẩu thất bại";
      throw Exception(message);
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await dio.post('/auth/forgot-password', data: {
        "email": email,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Lỗi gửi OTP");
    }
  }

  @override
  Future<void> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      await dio.post('/auth/reset-password', data: {
        "email": email,
        "otp": otp,
        "newPassword": newPassword,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Reset thất bại");
    }
  }

  @override
  Future<void> updateProfile(UpdateProfileRequestModel request) async {
    try {
      await dio.put(
        '/user/profile',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Cập nhật thất bại");
    }
  }

  @override
  Future<void> uploadAvatar(XFile file) async {
    try {
      final formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          file.path,
          filename: file.name,
        ),
      });

      await dio.post(
        '/user/upload-avatar',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data?["message"] ?? "Upload avatar thất bại");
    }
  }
}
