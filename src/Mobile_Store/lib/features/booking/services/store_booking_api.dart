// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../../../shared/token_storage.dart'; 
// import '/../core/api_constants.dart';
// import '../models/store_booking_model.dart';

// class StoreBookingApi {
//   static Future<Map<String, String>> _getHeaders() async {
//     final token = await TokenStorage.getAccessToken();
//     return {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token',
//     };
//   }

//   static dynamic _processResponse(http.Response response) {
//     final json = response.body.isNotEmpty ? jsonDecode(response.body) : {};
//     switch (response.statusCode) {
//       case 200: case 201: case 204: return json;
//       case 400: throw Exception(json['message'] ?? 'Dữ liệu không hợp lệ');
//       case 401: throw Exception('Phiên đăng nhập đã hết hạn');
//       case 403: throw Exception('Không có quyền thực hiện');
//       case 404: throw Exception(json['message'] ?? 'Không tìm thấy dữ liệu');
//       case 500: throw Exception('Lỗi máy chủ. Vui lòng thử lại sau');
//       default: throw Exception(json['message'] ?? 'Đã có lỗi xảy ra (${response.statusCode})');
//     }
//   }

//   // 1. Lấy danh sách booking
//   static Future<List<StoreBookingListModel>> getBookings({String? status}) async {
//     try {
//       final queryParam = status != null ? '?status=$status' : '';
//       final response = await http.get(
//         Uri.parse('${ApiConstants.baseUrl}/api/StoreBookings$queryParam'),
//         headers: await _getHeaders(),
//       ).timeout(const Duration(seconds: 20));

//       final json = _processResponse(response);
//       List data = json is List ? json : (json['data'] ?? []);
//       return data.map((e) => StoreBookingListModel.fromJson(e)).toList();
//     } catch (e) {
//       if (e.toString().startsWith('Exception: ')) rethrow;
//       throw Exception('Lỗi kết nối. Kiểm tra internet và thử lại');
//     }
//   }

//   // 2. Lấy chi tiết booking
//   static Future<StoreBookingDetailModel> getBookingDetail(int id) async {
//     try {
//       final response = await http.get(
//         Uri.parse('${ApiConstants.baseUrl}/api/StoreBookings/$id'),
//         headers: await _getHeaders(),
//       ).timeout(const Duration(seconds: 20));

//       final json = _processResponse(response);
//       return StoreBookingDetailModel.fromJson(json is Map<String, dynamic> ? json : json['data']);
//     } catch (e) {
//       if (e.toString().startsWith('Exception: ')) rethrow;
//       throw Exception('Lỗi kết nối');
//     }
//   }

//   // 3. Lấy nhân viên rảnh
//   static Future<List<AvailableStaffModel>> getAvailableStaffs({
//     required DateTime date,
//     required String startTime, // Format: "HH:mm:ss"
//     required String endTime,   // Format: "HH:mm:ss"
//   }) async {
//     try {
//       // C# TimeSpan cần truyền dạng HH:mm:ss
//       final dateStr = date.toIso8601String().split('T')[0];
//       final response = await http.get(
//         Uri.parse('${ApiConstants.baseUrl}/api/StoreBookings/available-staffs?date=$dateStr&startTime=$startTime&endTime=$endTime'),
//         headers: await _getHeaders(),
//       ).timeout(const Duration(seconds: 20));

//       final json = _processResponse(response);
//       List data = json is List ? json : (json['data'] ?? []);
//       return data.map((e) => AvailableStaffModel.fromJson(e)).toList();
//     } catch (e) {
//       if (e.toString().startsWith('Exception: ')) rethrow;
//       throw Exception('Lỗi kết nối');
//     }
//   }

//   // 4. Gán nhân viên và xác nhận
//   static Future<bool> assignStaff(int bookingId, List<Map<String, int>> assignments) async {
//     try {
//       final bodyData = {
//         "assignments": assignments // VD: [{"bookingDetailId": 1, "staffId": 2}]
//       };
//       final response = await http.put(
//         Uri.parse('${ApiConstants.baseUrl}/api/StoreBookings/$bookingId/assign-staff'),
//         headers: await _getHeaders(),
//         body: jsonEncode(bodyData),
//       ).timeout(const Duration(seconds: 20));

//       _processResponse(response);
//       return true;
//     } catch (e) {
//       if (e.toString().startsWith('Exception: ')) rethrow;
//       throw Exception('Lỗi kết nối');
//     }
//   }

//   // 5. Cập nhật trạng thái (Hủy / Hoàn thành)
//   static Future<bool> updateStatus(int bookingId, String status, {String? cancelReason}) async {
//     try {
//       final bodyData = {
//         "status": status,
//         "cancelReason": cancelReason
//       };
//       final response = await http.put(
//         Uri.parse('${ApiConstants.baseUrl}/api/StoreBookings/$bookingId/status'),
//         headers: await _getHeaders(),
//         body: jsonEncode(bodyData),
//       ).timeout(const Duration(seconds: 20));

//       _processResponse(response);
//       return true;
//     } catch (e) {
//       if (e.toString().startsWith('Exception: ')) rethrow;
//       throw Exception('Lỗi kết nối');
//     }
//   }
// }

import '../../../core/network/api_client.dart'; 
import '../models/store_booking_model.dart';

class StoreBookingApi {
  // 1. Lấy danh sách booking
  static Future<List<StoreBookingListModel>> getBookings({String? status}) async {
    final queryParam = status != null ? '?status=$status' : '';
    
    // ApiClient giờ trả thẳng về JSON đã bóc tách
    final json = await ApiClient.get('/api/StoreBookings$queryParam');
    
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => StoreBookingListModel.fromJson(e)).toList();
  }

  // 2. Lấy chi tiết booking
  static Future<StoreBookingDetailModel> getBookingDetail(int id) async {
    final json = await ApiClient.get('/api/StoreBookings/$id');
    return StoreBookingDetailModel.fromJson(json is Map<String, dynamic> ? json : json['data']);
  }

  // 3. Lấy nhân viên rảnh
  static Future<List<AvailableStaffModel>> getAvailableStaffs({
    required DateTime date,
    required String startTime,
    required String endTime,
  }) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final json = await ApiClient.get(
      '/api/StoreBookings/available-staffs?date=$dateStr&startTime=$startTime&endTime=$endTime'
    );
    
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => AvailableStaffModel.fromJson(e)).toList();
  }

  // 4. Gán nhân viên và xác nhận
  static Future<bool> assignStaff(int bookingId, List<Map<String, int>> assignments) async {
    // Không cần gán vào biến response nữa, gọi xong là tự động check lỗi rồi
    await ApiClient.put(
      '/api/StoreBookings/$bookingId/assign-staff',
      body: { "assignments": assignments },
    );
    return true;
  }

  // 5. Cập nhật trạng thái (Hủy / Hoàn thành)
  static Future<bool> updateStatus(int bookingId, String status, {String? cancelReason}) async {
    await ApiClient.put(
      '/api/StoreBookings/$bookingId/status',
      body: { "status": status, "cancelReason": cancelReason },
    );
    return true;
  }
}