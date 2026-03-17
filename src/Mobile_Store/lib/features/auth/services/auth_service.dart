// /* 
//    flutter clean 
//    flutter pub get
//    flutter run
//     */
// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../../../core/api_constants.dart';
// import '../models/login_response_model.dart';
// import '../models/register_response_model.dart';
// import '../../../shared/token_storage.dart'; 
// import 'package:jwt_decoder/jwt_decoder.dart';

// class AuthService {
//   static Future<AuthResult<LoginResponseModel>> login(
//     String emailOrPhone,
//     String password,
//   ) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('${ApiConstants.baseUrl}/api/Auth/login'),
//             headers: {'Content-Type': 'application/json'},
//             body: jsonEncode({
//               'emailOrPhone': emailOrPhone,
//               'password': password,
//             }),
//           )
//           .timeout(const Duration(seconds: 20));

//       final json = jsonDecode(response.body);

//       switch (response.statusCode) {
//         // case 200:
//         //   if (json['success'] == true) {
//         //     final data = json['data'];
//         //     return AuthResult.success(
//         //       LoginResponseModel(
//         //         accessToken: data['accessToken'],
//         //         refreshToken: data['refreshToken'],
//         //         role: data['role'] ?? '',       
//         //         storeStatus: data['storeStatus'],
//         //       ),
//         //     );
//         //   }

//         case 200:
//           if (json['success'] == true) {
//             final data = json['data'];
//             final String accessToken = data['accessToken'];
//             final String refreshToken = data['refreshToken'];

//             // 1. Giải mã Token để tìm storeId
//             try {
//               Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
              
//               // In ra console để xem cấu trúc thực tế Backend gửi gì (rất quan trọng khi debug)

//               // Các backend (đặc biệt là .NET) thường giấu ID ở 1 trong 3 key này. 
//               // Tôi viết sẵn code quét tự động cho bạn:
//               var rawId = decodedToken['sub'] ??
//                           decodedToken['storeId'] ?? 
//                           decodedToken['Id'] ?? 
//                           decodedToken['id'] ??
//                           decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];

//               if (rawId != null) {
//                 // Ép kiểu an toàn về số nguyên và lưu xuống máy
//                 int currentStoreId = int.parse(rawId.toString());
//                 await TokenStorage.saveStoreId(currentStoreId);
//                 ('✅ Đã lưu thành công StoreID = $currentStoreId xuống máy!');
//               } else {
//                 ('❌ CẢNH BÁO: Không tìm thấy bất kỳ ID nào trong Token!');
//               }
//             } catch (e) {
//               ('❌ Lỗi khi giải mã Token: $e');
//             }

//             // 2. Trả về kết quả như bình thường
//             return AuthResult.success(
//               LoginResponseModel(
//                 accessToken: accessToken,
//                 refreshToken: refreshToken,
//                 role: data['role'] ?? '',       
//                 storeStatus: data['storeStatus'],
//               ),
//             );
//           }
          
//           return AuthResult.failure(
//             json['message'] ?? 'Đăng nhập thất bại',
//           );

//         case 400:
//           return AuthResult.failure(
//             json['message'] ?? 'Dữ liệu không hợp lệ',
//           );

//         case 401:
//           return AuthResult.failure(
//             'Tài khoản hoặc mật khẩu không chính xác',
//           );

//         case 403:
//           return AuthResult.failure(
//             'Tài khoản của bạn đã bị khóa. Vui lòng liên hệ hỗ trợ',
//           );

//         case 500:
//           return AuthResult.failure('Lỗi máy chủ. Vui lòng thử lại sau');

//         default:
//           return AuthResult.failure(
//             json['message'] ?? 'Đã có lỗi xảy ra (${response.statusCode})',
//           );
//       }
//     } on TimeoutException {
//       return AuthResult.failure('Kết nối quá thời gian. Vui lòng thử lại');
//     } on FormatException {
//       return AuthResult.failure('Dữ liệu phản hồi không hợp lệ');
//     } catch (e) {
//       return AuthResult.failure('Lỗi kết nối. Kiểm tra internet và thử lại');
//     }
//   }


//   static Future<AuthResult<RegisterResponseModel>> registerPartner(
//     String ownerName,
//     String phone,
//     String email,
//     String password,
//   ) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('${ApiConstants.baseUrl}/api/Auth/register-partner'),
//             headers: {'Content-Type': 'application/json'},
//             body: jsonEncode({
//               'fullName': ownerName,
//               'phone': phone,
//               'email': email,
//               'password': password,
//             }),
//           )
//           .timeout(const Duration(seconds: 10));

//       final json = jsonDecode(response.body);

//       switch (response.statusCode) {
//         case 200:
//         case 201:
//           return AuthResult.success(
//             RegisterResponseModel.fromJson(json),
//           );

//         case 400:
//           return AuthResult.failure(
//             json['message'] ?? 'Thông tin đăng ký không hợp lệ',
//           );

//         case 409:
//           return AuthResult.failure(
//             'Email hoặc số điện thoại đã được đăng ký',
//           );

//         case 500:
//           return AuthResult.failure('Lỗi máy chủ. Vui lòng thử lại sau');

//         default:
//           return AuthResult.failure(
//             json['message'] ?? 'Đã có lỗi xảy ra (${response.statusCode})',
//           );
//       }
//     } on TimeoutException {
//       return AuthResult.failure('Kết nối quá thời gian. Vui lòng thử lại');
//     } on FormatException {
//       return AuthResult.failure('Dữ liệu phản hồi không hợp lệ');
//     } catch (e) {
//       return AuthResult.failure('Lỗi kết nối. Kiểm tra internet và thử lại');
//     }
//   }

//   static Future<AuthResult<String>> logout() async {
//     try {
//       // 1. Dùng TokenStorage để lấy token
//       final token = await TokenStorage.getAccessToken();

//       // Nếu không có token, coi như đã đăng xuất thành công
//       if (token == null) {
//         return AuthResult.success('Đã đăng xuất');
//       }

//       // 2. Gọi API đăng xuất
//       final response = await http
//           .post(
//             Uri.parse('${ApiConstants.baseUrl}/api/Auth/logout'),
//             headers: {
//               'Content-Type': 'application/json',
//               'Authorization': 'Bearer $token',
//             },
//           )
//           .timeout(const Duration(seconds: 10));

//       // 3. Xóa token ở local ngay khi gọi API xong bằng TokenStorage
//       await TokenStorage.clearTokens();

//       // 4. Xử lý kết quả
//       if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 401) {
//          return AuthResult.success('Đăng xuất thành công');
//       } else if (response.statusCode == 500) {
//          return AuthResult.failure('Lỗi máy chủ. Vui lòng thử lại sau');
//       } else {
//          String errorMessage = 'Đã có lỗi xảy ra (${response.statusCode})';
//          if (response.body.isNotEmpty) {
//            final json = jsonDecode(response.body);
//            errorMessage = json['message'] ?? errorMessage;
//          }
//          return AuthResult.failure(errorMessage);
//       }

//     } on TimeoutException {
//       // Mất mạng: Vẫn ép xóa token
//       await TokenStorage.clearTokens();
//       return AuthResult.success('Đăng xuất ngoại tuyến (kết nối chậm)');
      
//     } on FormatException {
//       return AuthResult.failure('Dữ liệu phản hồi không hợp lệ');
      
//     } catch (e) {
//       // Lỗi bất ngờ: Vẫn ép xóa token ở máy
//       await TokenStorage.clearTokens();
//       return AuthResult.success('Đăng xuất ngoại tuyến (lỗi mạng)');
//     }
//   }

// static Future<AuthResult<bool>> forgotPassword(String email) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('${ApiConstants.baseUrl}/api/Auth/forgot-password'),
//             headers: {'Content-Type': 'application/json'},
//             body: jsonEncode({
//               'email': email,
//             }),
//           )
//           .timeout(const Duration(seconds: 20));

//       final json = jsonDecode(response.body);

//       switch (response.statusCode) {
//         case 200:
//           // Nếu backend của bạn có trường 'success' giống login
//           if (json['success'] == true || json['success'] == null) {
//             return AuthResult.success(true);
//           }
          
//           return AuthResult.failure(
//             json['message'] ?? 'Gửi yêu cầu thất bại',
//           );

//         case 400:
//           return AuthResult.failure(
//             json['message'] ?? 'Email không hợp lệ hoặc dữ liệu sai',
//           );

//         case 404: // Rất hay dùng trong Forgot Password nếu email không tồn tại
//           return AuthResult.failure(
//             json['message'] ?? 'Không tìm thấy tài khoản với email này',
//           );

//         case 500:
//           return AuthResult.failure('Lỗi máy chủ. Vui lòng thử lại sau');

//         default:
//           return AuthResult.failure(
//             json['message'] ?? 'Đã có lỗi xảy ra (${response.statusCode})',
//           );
//       }
//     } on TimeoutException {
//       return AuthResult.failure('Kết nối quá thời gian. Vui lòng thử lại');
//     } on FormatException {
//       return AuthResult.failure('Dữ liệu phản hồi không hợp lệ');
//     } catch (e) {
//       return AuthResult.failure('Lỗi kết nối. Kiểm tra internet và thử lại');
//     }
//   }

//   // lib/features/auth/services/auth_service.dart

//   static Future<AuthResult<bool>> resetPassword(
//     String email, 
//     String otp, // Đổi tên biến thành otp cho chuẩn
//     String newPassword,
//   ) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('${ApiConstants.baseUrl}/api/Auth/reset-password'),
//             headers: {'Content-Type': 'application/json'},
//             body: jsonEncode({
//               'email': email,
//               'otp': otp, // SỬA CHỖ NÀY: Dùng key 'otp' theo đúng request của bạn
//               'newPassword': newPassword,
//             }),
//           )
//           .timeout(const Duration(seconds: 20));

//       final json = jsonDecode(response.body);

//       switch (response.statusCode) {
//         case 200:
//           if (json['success'] == true || json['success'] == null) {
//             return AuthResult.success(true);
//           }
//           return AuthResult.failure(json['message'] ?? 'Đặt lại mật khẩu thất bại');

//         case 400:
//           return AuthResult.failure(json['message'] ?? 'Mã OTP không hợp lệ hoặc đã hết hạn');

//         case 500:
//           return AuthResult.failure('Lỗi máy chủ. Vui lòng thử lại sau');

//         default:
//           return AuthResult.failure(json['message'] ?? 'Đã có lỗi xảy ra (${response.statusCode})');
//       }
//     } on TimeoutException {
//       return AuthResult.failure('Kết nối quá thời gian. Vui lòng thử lại');
//     } on FormatException {
//       return AuthResult.failure('Dữ liệu phản hồi không hợp lệ');
//     } catch (e) {
//       return AuthResult.failure('Lỗi kết nối. Kiểm tra internet và thử lại');
//     }
//   }
// }
// class AuthResult<T> {
//   final bool isSuccess;
//   final T? data;
//   final String? errorMessage;

//   AuthResult.success(this.data)
//       : isSuccess = true,
//         errorMessage = null;

//   AuthResult.failure(this.errorMessage)
//       : isSuccess = false,
//         data = null;
// }
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../core/network/api_client.dart';
import '../models/login_response_model.dart';
import '../models/register_response_model.dart';
import '../../../shared/token_storage.dart';

class AuthService {
  // Hàm nhỏ để bóc tách câu thông báo lỗi
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
       
        // 1. Lấy CHÍNH XÁC StoreId (Thường backend hay viết thường 'storeId' hoặc viết hoa 'StoreId')
        var rawStoreId = decoded['storeId'] ?? decoded['StoreId'];
       if (rawStoreId != null) {
          int sid = int.parse(rawStoreId.toString());
         
          await TokenStorage.saveStoreId(sid); // Nhớ thêm await ở đây cho chắc
        }

        // 2. (Tùy chọn) Lấy UserId riêng biệt nếu app của bạn cần dùng
        var rawUserId = decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ?? decoded['Id'] ?? decoded['id'] ?? decoded['sub'];
        if (rawUserId != null) {
          // Nếu trong TokenStorage của bạn có hàm saveUserId thì mở comment dòng dưới ra:
          // TokenStorage.saveUserId(int.parse(rawUserId.toString())); 
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
      await ApiClient.post('/api/Auth/logout'); // ApiClient tự lo gắn Token
      await TokenStorage.clearTokens();
      return AuthResult.success('Đăng xuất thành công');
    } catch (e) {
      // Nếu mất mạng hoặc lỗi server thì vẫn xóa token cục bộ
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