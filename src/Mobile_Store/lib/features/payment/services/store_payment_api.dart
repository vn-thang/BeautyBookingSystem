// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../../../shared/token_storage.dart'; 
// import '/../core/api_constants.dart';
// import '../models/store_payment_model.dart'; // Đảm bảo bạn đã có model này từ bài trước

// class StorePaymentApi {
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

//   // 1. Lấy danh sách thanh toán
//   static Future<List<StorePaymentModel>> getPayments() async {
//     try {
//       final response = await http.get(
//         Uri.parse('${ApiConstants.baseUrl}/api/StorePayments'),
//         headers: await _getHeaders(),
//       ).timeout(const Duration(seconds: 20));

//       final json = _processResponse(response);
//       List data = json is List ? json : (json['data'] ?? []);
//       return data.map((e) => StorePaymentModel.fromJson(e)).toList();
//     } catch (e) {
//       if (e.toString().startsWith('Exception: ')) rethrow;
//       throw Exception('Lỗi kết nối. Kiểm tra internet và thử lại');
//     }
//   }

//   // 2. Xác nhận thu tiền
//   static Future<bool> confirmPayment(int id, {String? transactionId}) async {
//     try {
//       final bodyData = {
//         if (transactionId != null && transactionId.isNotEmpty) "transactionId": transactionId
//       };
      
//       final response = await http.put(
//         Uri.parse('${ApiConstants.baseUrl}/api/StorePayments/$id/confirm'),
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

//   // 3. Hoàn tiền
//   static Future<bool> refundPayment(int id) async {
//     try {
//       final response = await http.put(
//         Uri.parse('${ApiConstants.baseUrl}/api/StorePayments/$id/refund'),
//         headers: await _getHeaders(),
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
import '../models/store_payment_model.dart';

class StorePaymentApi {
  // 1. Lấy danh sách thanh toán
  static Future<List<StorePaymentModel>> getPayments() async {
    final json = await ApiClient.get('/api/StorePayments');
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => StorePaymentModel.fromJson(e)).toList();
  }

  // 2. Xác nhận thu tiền
  static Future<bool> confirmPayment(int id, {String? transactionId}) async {
    final bodyData = {
      if (transactionId != null && transactionId.isNotEmpty) "transactionId": transactionId
    };
    await ApiClient.put(
      '/api/StorePayments/$id/confirm', 
      body: bodyData.isNotEmpty ? bodyData : null,
    );
    return true;
  }

  // 3. Hoàn tiền
  static Future<bool> refundPayment(int id) async {
    await ApiClient.put('/api/StorePayments/$id/refund');
    return true;
  }
}