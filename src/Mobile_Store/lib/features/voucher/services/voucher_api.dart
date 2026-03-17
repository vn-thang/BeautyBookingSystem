// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../../../shared/token_storage.dart'; 
// import '/../core/api_constants.dart';
// import '../models/voucher_model.dart';

// class VoucherApi {
//   // --- HÀM HỖ TRỢ LẤY HEADER ---
//   static Future<Map<String, String>> _getHeaders() async {
//     final token = await TokenStorage.getAccessToken();
//     return {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token',
//     };
//   }

//   // --- HÀM HỖ TRỢ KIỂM TRA STATUS CODE ---
//   static dynamic _processResponse(http.Response response) {
//     // Nếu body rỗng, gán thành JSON rỗng để không bị lỗi FormatException
//     final json = response.body.isNotEmpty ? jsonDecode(response.body) : {};

//     switch (response.statusCode) {
//       case 200:
//       case 201:
//       case 204:
//         return json;

//       case 400:
//         throw Exception(json['message'] ?? 'Dữ liệu không hợp lệ');

//       case 401:
//         throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại');

//       case 403:
//         throw Exception('Tài khoản của bạn không có quyền thực hiện thao tác này');
        
//       case 404:
//         throw Exception(json['message'] ?? 'Không tìm thấy dữ liệu khuyến mãi');

//       case 500:
//         throw Exception('Lỗi máy chủ. Vui lòng thử lại sau');

//       default:
//         throw Exception(json['message'] ?? 'Đã có lỗi xảy ra (${response.statusCode})');
//     }
//   }

//   // ==========================================
//   // 1. LẤY DANH SÁCH VOUCHER CỦA CỬA HÀNG
//   // ==========================================
//   static Future<List<VoucherModel>> getVouchers() async {
//     try {
//       final response = await http.get(
//         Uri.parse('${ApiConstants.baseUrl}/api/store-vouchers'),
//         headers: await _getHeaders(),
//       ).timeout(const Duration(seconds: 20));

//       final json = _processResponse(response);
      
//       // Map dữ liệu
//       List data = json is List ? json : (json['data'] ?? []);
//       return data.map((e) => VoucherModel.fromJson(e)).toList();

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
//   // 2. LẤY CHI TIẾT 1 VOUCHER
//   // ==========================================
//   static Future<VoucherModel> getVoucherById(int id) async {
//     try {
//       final response = await http.get(
//         Uri.parse('${ApiConstants.baseUrl}/api/store-vouchers/$id'),
//         headers: await _getHeaders(),
//       ).timeout(const Duration(seconds: 20));

//       final json = _processResponse(response);
//       return VoucherModel.fromJson(json is Map<String, dynamic> ? json : json['data']);

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
//   // 3. TẠO VOUCHER MỚI
//   // ==========================================
//   static Future<VoucherModel> createVoucher({
//     required String code,
//     int? serviceId,
//     required int discountType,
//     required double discountValue,
//     required double minOrderValue,
//     required double maxDiscount,
//     required DateTime startDate,
//     required DateTime endDate,
//     required int usageLimit,
//   }) async {
//     try {
//       final bodyData = {
//         "code": code,
//         "serviceId": serviceId,
//         "discountType": discountType,
//         "discountValue": discountValue,
//         "minOrderValue": minOrderValue,
//         "maxDiscount": maxDiscount,
//         "startDate": startDate.toUtc().toIso8601String(),
//         "endDate": endDate.toUtc().toIso8601String(),
//         "usageLimit": usageLimit,
//       };

//       final response = await http.post(
//         Uri.parse('${ApiConstants.baseUrl}/api/store-vouchers'),
//         headers: await _getHeaders(),
//         body: jsonEncode(bodyData),
//       ).timeout(const Duration(seconds: 20));

//       final json = _processResponse(response);
//       return VoucherModel.fromJson(json is Map<String, dynamic> ? json : json['data']);

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
//   // 4. SỬA VOUCHER (Theo API của bạn, chỉ sửa EndDate và UsageLimit)
//   // ==========================================
//   static Future<void> updateVoucher({
//     required int id,
//     required DateTime endDate,
//     required int usageLimit,
//   }) async {
//     try {
//       final bodyData = {
//         "endDate": endDate.toUtc().toIso8601String(),
//         "usageLimit": usageLimit,
//       };

//       final response = await http.put(
//         Uri.parse('${ApiConstants.baseUrl}/api/store-vouchers/$id'),
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
//   // 5. XÓA VOUCHER
//   // ==========================================
//   static Future<void> deleteVoucher(int id) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('${ApiConstants.baseUrl}/api/store-vouchers/$id'),
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
import '../models/voucher_model.dart';

class VoucherApi {
  // 1. Lấy danh sách Voucher
  static Future<List<VoucherModel>> getVouchers() async {
    final json = await ApiClient.get('/api/store-vouchers');
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => VoucherModel.fromJson(e)).toList();
  }

  // 2. Lấy chi tiết Voucher
  static Future<VoucherModel> getVoucherById(int id) async {
    final json = await ApiClient.get('/api/store-vouchers/$id');
    return VoucherModel.fromJson(json is Map<String, dynamic> ? json : json['data']);
  }

  // 3. Tạo Voucher
  static Future<VoucherModel> createVoucher({
    required String code, int? serviceId, required int discountType,
    required double discountValue, required double minOrderValue,
    required double maxDiscount, required DateTime startDate,
    required DateTime endDate, required int usageLimit,
  }) async {
    final json = await ApiClient.post('/api/store-vouchers', body: {
      "code": code, "serviceId": serviceId, "discountType": discountType,
      "discountValue": discountValue, "minOrderValue": minOrderValue,
      "maxDiscount": maxDiscount,
      "startDate": startDate.toUtc().toIso8601String(),
      "endDate": endDate.toUtc().toIso8601String(),
      "usageLimit": usageLimit,
    });
    return VoucherModel.fromJson(json is Map<String, dynamic> ? json : json['data']);
  }

  // 4. Sửa Voucher
  static Future<void> updateVoucher({required int id, required DateTime endDate, required int usageLimit}) async {
    await ApiClient.put('/api/store-vouchers/$id', body: {
      "endDate": endDate.toUtc().toIso8601String(),
      "usageLimit": usageLimit,
    });
  }

  // 5. Xóa Voucher
  static Future<void> deleteVoucher(int id) async {
    await ApiClient.delete('/api/store-vouchers/$id');
  }
}