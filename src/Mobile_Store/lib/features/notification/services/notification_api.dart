// // import 'dart:async';
// // import 'dart:convert';
// // import 'package:http/http.dart' as http;
// // import '../../../shared/token_storage.dart'; 
// // import '/../core/api_constants.dart';
// // import '../models/notification_model.dart'; 

// // class NotificationApi {
// //   // --- Hàm hỗ trợ cấu hình Header ---
// //   static Future<Map<String, String>> _getHeaders() async {
// //     final token = await TokenStorage.getAccessToken();
// //     return {
// //       'Content-Type': 'application/json',
// //       'Authorization': 'Bearer $token',
// //     };
// //   }

// //   // --- Hàm hỗ trợ xử lý Response và StatusCode ---
// //   static dynamic _processResponse(http.Response response) {
// //     final json = response.body.isNotEmpty ? jsonDecode(response.body) : {};
// //     switch (response.statusCode) {
// //       case 200: case 201: case 204: return json;
// //       case 400: throw Exception(json['message'] ?? 'Dữ liệu không hợp lệ');
// //       case 401: throw Exception('Phiên đăng nhập đã hết hạn');
// //       case 403: throw Exception('Không có quyền thực hiện');
// //       case 404: throw Exception(json['message'] ?? 'Không tìm thấy dữ liệu');
// //       case 500: throw Exception('Lỗi máy chủ. Vui lòng thử lại sau');
// //       default: throw Exception(json['message'] ?? 'Đã có lỗi xảy ra (${response.statusCode})');
// //     }
// //   }

// //   // 1. Cập nhật FCM Token (để nhận Push Notification)
// //   static Future<bool> updateFcmToken(String fcmToken) async {
// //     try {
// //       final response = await http.put(
// //         Uri.parse('${ApiConstants.baseUrl}/api/Notifications/fcm-token'),
// //         headers: await _getHeaders(),
// //         body: jsonEncode({'fcmToken': fcmToken}),
// //       ).timeout(const Duration(seconds: 20));

// //       _processResponse(response);
// //       return true;
// //     } catch (e) {
// //       if (e.toString().startsWith('Exception: ')) rethrow;
// //       throw Exception('Lỗi kết nối. Không thể cập nhật FcmToken.');
// //     }
// //   }

// //   // 2. Lấy danh sách thông báo (có phân trang)
// //   static Future<List<NotificationModel>> getNotifications({int pageIndex = 1, int pageSize = 20}) async {
// //     try {
// //       final response = await http.get(
// //         Uri.parse('${ApiConstants.baseUrl}/api/Notifications?pageIndex=$pageIndex&pageSize=$pageSize'),
// //         headers: await _getHeaders(),
// //       ).timeout(const Duration(seconds: 20));

// //       final json = _processResponse(response);
// //       List data = json is List ? json : (json['data'] ?? []);
// //       return data.map((e) => NotificationModel.fromJson(e)).toList();
// //     } catch (e) {
// //       if (e.toString().startsWith('Exception: ')) rethrow;
// //       throw Exception('Lỗi kết nối. Kiểm tra internet và thử lại');
// //     }
// //   }

// //   // 3. Lấy số lượng thông báo chưa đọc
// //   static Future<int> getUnreadCount() async {
// //     try {
// //       final response = await http.get(
// //         Uri.parse('${ApiConstants.baseUrl}/api/Notifications/unread-count'),
// //         headers: await _getHeaders(),
// //       ).timeout(const Duration(seconds: 20));

// //       final json = _processResponse(response);
// //       return json['count'] ?? 0;
// //     } catch (e) {
// //       if (e.toString().startsWith('Exception: ')) rethrow;
// //       throw Exception('Lỗi kết nối khi lấy số lượng thông báo.');
// //     }
// //   }

// //   // 4. Đánh dấu 1 thông báo là đã đọc
// //   static Future<bool> markAsRead(int id) async {
// //     try {
// //       final response = await http.patch(
// //         Uri.parse('${ApiConstants.baseUrl}/api/Notifications/$id/read'),
// //         headers: await _getHeaders(),
// //       ).timeout(const Duration(seconds: 20));

// //       _processResponse(response);
// //       return true;
// //     } catch (e) {
// //       if (e.toString().startsWith('Exception: ')) rethrow;
// //       throw Exception('Lỗi kết nối.');
// //     }
// //   }

// //   // 5. Đánh dấu tất cả là đã đọc
// //   static Future<bool> markAllAsRead() async {
// //     try {
// //       final response = await http.patch(
// //         Uri.parse('${ApiConstants.baseUrl}/api/Notifications/read-all'),
// //         headers: await _getHeaders(),
// //       ).timeout(const Duration(seconds: 20));

// //       _processResponse(response);
// //       return true;
// //     } catch (e) {
// //       if (e.toString().startsWith('Exception: ')) rethrow;
// //       throw Exception('Lỗi kết nối.');
// //     }
// //   }
// // }

// import 'dart:convert';
// import '../../../core/network/api_client.dart';
// import '../models/notification_model.dart'; 

// class NotificationApi {
//   // --- Hàm hỗ trợ xử lý Response chung ---
//   static dynamic _processResponse(dynamic response) {
//     final json = response.body.isNotEmpty ? jsonDecode(response.body) : {};
//     switch (response.statusCode) {
//       case 200: case 201: case 204: return json;
//       case 400: throw Exception(json['message'] ?? 'Dữ liệu không hợp lệ');
//       case 403: throw Exception('Không có quyền thực hiện');
//       case 404: throw Exception(json['message'] ?? 'Không tìm thấy dữ liệu');
//       case 500: throw Exception('Lỗi máy chủ. Vui lòng thử lại sau');
//       default: throw Exception(json['message'] ?? 'Đã có lỗi xảy ra (${response.statusCode})');
//     }
//   }

//   // 1. Cập nhật FCM Token
//   static Future<bool> updateFcmToken(String fcmToken) async {
//     try {
//       final response = await ApiClient.put(
//         '/api/Notifications/fcm-token',
//         body: {'fcmToken': fcmToken},
//       );
//       _processResponse(response);
//       return true;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // 2. Lấy danh sách thông báo
//   static Future<List<NotificationModel>> getNotifications({int pageIndex = 1, int pageSize = 20}) async {
//     try {
//       final response = await ApiClient.get(
//         '/api/Notifications?pageIndex=$pageIndex&pageSize=$pageSize'
//       );
//       final json = _processResponse(response);
//       List data = json is List ? json : (json['data'] ?? []);
//       return data.map((e) => NotificationModel.fromJson(e)).toList();
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // 3. Lấy số lượng chưa đọc
//   static Future<int> getUnreadCount() async {
//     try {
//       final response = await ApiClient.get('/api/Notifications/unread-count');
//       final json = _processResponse(response);
//       return json['count'] ?? 0;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // 4. Đánh dấu 1 thông báo là đã đọc
//   static Future<bool> markAsRead(int id) async {
//     try {
//       final response = await ApiClient.put('/api/Notifications/$id/read');
//       _processResponse(response);
//       return true;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // 5. Đánh dấu tất cả là đã đọc
//   static Future<bool> markAllAsRead() async {
//     try {
//       final response = await ApiClient.put('/api/Notifications/read-all');
//       _processResponse(response);
//       return true;
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
import '../../../core/network/api_client.dart';
import '../models/notification_model.dart'; 

class NotificationApi {
  // 1. Cập nhật FCM Token
  static Future<bool> updateFcmToken(String fcmToken) async {
    await ApiClient.put('/api/Notifications/fcm-token', body: {'fcmToken': fcmToken});
    return true;
  }

  // 2. Lấy danh sách thông báo
  static Future<List<NotificationModel>> getNotifications({int pageIndex = 1, int pageSize = 20}) async {
    final json = await ApiClient.get('/api/Notifications?pageIndex=$pageIndex&pageSize=$pageSize');
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  // 3. Lấy số lượng chưa đọc
  static Future<int> getUnreadCount() async {
    final json = await ApiClient.get('/api/Notifications/unread-count');
    return json['count'] ?? 0;
  }

  // 4. Đánh dấu 1 thông báo là đã đọc
  static Future<bool> markAsRead(int id) async {
    await ApiClient.put('/api/Notifications/$id/read');
    return true;
  }

  // 5. Đánh dấu tất cả là đã đọc
  static Future<bool> markAllAsRead() async {
    await ApiClient.put('/api/Notifications/read-all');
    return true;
  }
}