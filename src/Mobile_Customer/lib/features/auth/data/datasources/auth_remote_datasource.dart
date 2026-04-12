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

  String _extractMessage(dynamic data, String fallback) {
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'] ?? data['title'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString().trim();
      }

      final nestedData = data['data'];
      if (nestedData is Map<String, dynamic>) {
        final nestedMessage =
            nestedData['message'] ?? nestedData['error'] ?? nestedData['title'];
        if (nestedMessage != null &&
            nestedMessage.toString().trim().isNotEmpty) {
          return nestedMessage.toString().trim();
        }
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    return fallback;
  }

  dynamic _unwrapData(dynamic body) {
    if (body is Map<String, dynamic>) {
      return body['data'] ?? body;
    }
    return body;
  }

  String _mapDioException(DioException e, String fallback) {
    final responseData = e.response?.data;
    return _extractMessage(responseData, fallback);
  }

  @override
  Future<LoginResponseModel> login(String emailOrPhone, String password) async {
    try {
      final response = await dio.post(
        'auth/login',
        data: {
          "emailOrPhone": emailOrPhone,
          "password": password,
        },
      );

      final data = response.data["data"] ?? response.data;
      return LoginResponseModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      // QUAN TRỌNG: giữ message từ BE
      final message = _extractMessage(
        e.response?.data,
        "Số điện thoại/Email hoặc mật khẩu không đúng.",
      );

      throw Exception(message);
    }
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
      throw Exception(_mapDioException(
        e,
        "Không lấy được thông tin người dùng",
      ));
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
      final response = await dio.post(
        'auth/register',
        data: {
          "fullName": fullName,
          "phone": phone,
          "email": email,
          "password": password,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final body = response.data;

      if (body is Map<String, dynamic> && body["success"] == false) {
        throw Exception(
          _extractMessage(body, "Đăng ký thất bại"),
        );
      }

      final data = _unwrapData(body);
      return LoginResponseModel.fromJson(
        Map<String, dynamic>.from(data as Map),
      );
    } on DioException catch (e) {
      throw Exception(_mapDioException(e, "Đăng ký thất bại"));
    }
  }

  @override
  Future<LoginResponseModel> refreshToken(
    String accessToken,
    String refreshToken,
  ) async {
    try {
      final response = await dio.post(
        'auth/refresh-token',
        data: {
          "accessToken": accessToken,
          "refreshToken": refreshToken,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final body = response.data;

      if (body is Map<String, dynamic> && body["success"] == false) {
        throw Exception(
          _extractMessage(body, "Làm mới token thất bại"),
        );
      }

      final data = _unwrapData(body);
      return LoginResponseModel.fromJson(
        Map<String, dynamic>.from(data as Map),
      );
    } on DioException catch (e) {
      throw Exception(
        _mapDioException(
          e,
          "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.",
        ),
      );
    }
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await dio.put('auth/change-password', data: {
        "oldPassword": oldPassword,
        "newPassword": newPassword,
      });
    } on DioException catch (e) {
      throw Exception(_mapDioException(e, "Đổi mật khẩu thất bại"));
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await dio.post('auth/forgot-password', data: {
        "email": email,
      });
    } on DioException catch (e) {
      throw Exception(_mapDioException(e, "Gửi OTP thất bại"));
    }
  }

  @override
  Future<void> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      await dio.post('auth/reset-password', data: {
        "email": email,
        "otp": otp,
        "newPassword": newPassword,
      });
    } on DioException catch (e) {
      throw Exception(_mapDioException(e, "Đổi mật khẩu thất bại"));
    }
  }

  @override
  Future<void> updateProfile(UpdateProfileRequestModel request) async {
    try {
      await dio.put(
        'customer/customeruser/profile',
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(_mapDioException(e, "Cập nhật thông tin thất bại"));
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
        'customer/customeruser/upload-avatar',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      throw Exception(_mapDioException(e, "Upload avatar thất bại"));
    }
  }
}
