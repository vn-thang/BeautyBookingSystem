// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../../../shared/token_storage.dart'; 
// import '/../core/api_constants.dart';
// import '../models/staff_model.dart';

// class StaffApi {
//   // --- HÀM HỖ TRỢ LẤY HEADER ---
//   static Future<Map<String, String>> _getHeaders() async {
//     final token = await TokenStorage.getAccessToken();
//     return {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token', 
//     };
//   }

//   // --- HÀM HỖ TRỢ KIỂM TRA STATUS CODE (Chuẩn hóa theo mẫu AuthService của bạn) ---
//   static dynamic _processResponse(http.Response response) {
//     // Nếu body rỗng (thường gặp ở DELETE/PUT), gán thành JSON rỗng để không bị lỗi FormatException
//     final json = response.body.isNotEmpty ? jsonDecode(response.body) : {};

//     switch (response.statusCode) {
//       case 200:
//       case 201:
//       case 204: // 204 No Content thường dùng khi Update/Delete thành công mà không trả về data
//         return json;

//       case 400:
//         throw Exception(json['message'] ?? 'Dữ liệu không hợp lệ');

//       case 401:
//         throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại');

//       case 403:
//         throw Exception('Tài khoản của bạn không có quyền thực hiện thao tác này');
        
//       case 404:
//         throw Exception(json['message'] ?? 'Không tìm thấy dữ liệu nhân viên');

//       case 500:
//         throw Exception('Lỗi máy chủ. Vui lòng thử lại sau');

//       default:
//         throw Exception(json['message'] ?? 'Đã có lỗi xảy ra (${response.statusCode})');
//     }
//   }

//   // ==========================================
//   // 1. LẤY DANH SÁCH NHÂN VIÊN
//   // ==========================================
//   static Future<List<StaffModel>> getStaffs({bool onlyActive = false}) async {
//     try {
//       final response = await http.get(
//         Uri.parse('${ApiConstants.baseUrl}/api/Staffs?onlyActive=$onlyActive'),
//         headers: await _getHeaders(),
//       ).timeout(const Duration(seconds: 20));

//       final json = _processResponse(response);
      
//       // Map dữ liệu
//       List data = json is List ? json : (json['data'] ?? []);
//       return data.map((e) => StaffModel.fromJson(e)).toList();

//     } on TimeoutException {
//       throw Exception('Kết nối quá thời gian. Vui lòng thử lại');
//     } on FormatException {
//       throw Exception('Dữ liệu phản hồi không hợp lệ');
//     } catch (e) {
//       // Giữ nguyên message nếu lỗi đã được throw từ _processResponse
//       if (e.toString().startsWith('Exception: ')) {
//         rethrow; 
//       }
//       throw Exception('Lỗi kết nối. Kiểm tra internet và thử lại');
//     }
//   }

//   // ==========================================
//   // 2. THÊM NHÂN VIÊN
//   // ==========================================
//   static Future<void> createStaff({
//     required String fullName,
//     required String position,
//     String? avatarUrl,
//   }) async {
//     try {
//       final bodyData = {
//         "fullName": fullName,
//         "position": position,
//         "avatarUrl": (avatarUrl?.trim().isEmpty ?? true) ? null : avatarUrl,
//       };

//       final response = await http.post(
//         Uri.parse('${ApiConstants.baseUrl}/api/Staffs'),
//         headers: await _getHeaders(),
//         body: jsonEncode(bodyData),
//       ).timeout(const Duration(seconds: 20));

//       _processResponse(response);

//     } on TimeoutException {
//       throw Exception('Kết nối quá thời gian. Vui lòng thử lại');
//     } on FormatException {
//       throw Exception('Dữ liệu phản hồi không hợp lệ');
//     } catch (e) {
//       if (e.toString().startsWith('Exception: ')) rethrow;
//       throw Exception('Lỗi kết nối. Kiểm tra internet và thử lại');
//     }
//   }

//   // ==========================================
//   // 3. SỬA NHÂN VIÊN
//   // ==========================================
//   static Future<void> updateStaff({
//     required int id,
//     required String fullName,
//     required String position,
//     String? avatarUrl,
//     required bool isActive,
//   }) async {
//     try {
//       final bodyData = {
//         "fullName": fullName,
//         "position": position,
//         "avatarUrl": (avatarUrl?.trim().isEmpty ?? true) ? null : avatarUrl,
//         "isActive": isActive,
//       };

//       final response = await http.put(
//         Uri.parse('${ApiConstants.baseUrl}/api/Staffs/$id'),
//         headers: await _getHeaders(),
//         body: jsonEncode(bodyData),
//       ).timeout(const Duration(seconds: 20));

//       _processResponse(response);

//     } on TimeoutException {
//       throw Exception('Kết nối quá thời gian. Vui lòng thử lại');
//     } on FormatException {
//       throw Exception('Dữ liệu phản hồi không hợp lệ');
//     } catch (e) {
//       if (e.toString().startsWith('Exception: ')) rethrow;
//       throw Exception('Lỗi kết nối. Kiểm tra internet và thử lại');
//     }
//   }

//   // ==========================================
//   // 4. XÓA NHÂN VIÊN
//   // ==========================================
//   static Future<void> deleteStaff(int id) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('${ApiConstants.baseUrl}/api/Staffs/$id'),
//         headers: await _getHeaders(),
//       ).timeout(const Duration(seconds: 20));

//       _processResponse(response);

//     } on TimeoutException {
//       throw Exception('Kết nối quá thời gian. Vui lòng thử lại');
//     } on FormatException {
//       throw Exception('Dữ liệu phản hồi không hợp lệ');
//     } catch (e) {
//       if (e.toString().startsWith('Exception: ')) rethrow;
//       throw Exception('Lỗi kết nối. Kiểm tra internet và thử lại');
//     }
//   }
// }

import '../../../core/network/api_client.dart';
import '../models/staff_model.dart';

class StaffApi {
  // 1. Lấy danh sách nhân viên
  static Future<List<StaffModel>> getStaffs({bool onlyActive = false}) async {
    final json = await ApiClient.get('/api/Staffs?onlyActive=$onlyActive');
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => StaffModel.fromJson(e)).toList();
  }

  // 2. Thêm nhân viên
  static Future<void> createStaff({required String fullName, required String position, String? avatarUrl}) async {
    await ApiClient.post('/api/Staffs', body: {
      "fullName": fullName,
      "position": position,
      "avatarUrl": (avatarUrl?.trim().isEmpty ?? true) ? null : avatarUrl,
    });
  }

  // 3. Sửa nhân viên
  static Future<void> updateStaff({
    required int id, required String fullName, required String position,
    String? avatarUrl, required bool isActive,
  }) async {
    await ApiClient.put('/api/Staffs/$id', body: {
      "fullName": fullName,
      "position": position,
      "avatarUrl": (avatarUrl?.trim().isEmpty ?? true) ? null : avatarUrl,
      "isActive": isActive,
    });
  }

  // 4. Xóa nhân viên
  static Future<void> deleteStaff(int id) async {
    await ApiClient.delete('/api/Staffs/$id');
  }
}