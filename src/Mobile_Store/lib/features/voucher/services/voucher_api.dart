import '../../../core/network/api_client.dart';
import '../models/voucher_model.dart';

class VoucherApi {
  static Future<List<VoucherModel>> getVouchers() async {
    final json = await ApiClient.get('/api/store-vouchers');
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => VoucherModel.fromJson(e)).toList();
  }

  static Future<VoucherModel> getVoucherById(int id) async {
    final json = await ApiClient.get('/api/store-vouchers/$id');
    return VoucherModel.fromJson(json is Map<String, dynamic> ? json : json['data']);
  }
static Future<VoucherModel> createVoucher({
    required String code, 
    int? serviceId, 
    String? imageUrl, 
    required int discountType,
    required double discountValue, 
    required double minOrderValue,
    required double maxDiscount, 
    required DateTime startDate,
    required DateTime endDate, 
    required int usageLimit,
  }) async {
    final json = await ApiClient.post('/api/store-vouchers', body: {
      "code": code, 
      "serviceId": serviceId, 
      "imageUrl": imageUrl,
      "discountType": discountType,
      "discountValue": discountValue, 
      "minOrderValue": minOrderValue,
      "maxDiscount": maxDiscount,
      "startDate": startDate.toUtc().toIso8601String(),
      "endDate": endDate.toUtc().toIso8601String(),
      "usageLimit": usageLimit,
    });
    return VoucherModel.fromJson(json is Map<String, dynamic> ? json : json['data']);
  }

  static Future<void> updateVoucher({
    required int id, 
    required DateTime endDate, 
    required int usageLimit,
    int? serviceId,
    String? imageUrl, 
  }) async {
    await ApiClient.put('/api/store-vouchers/$id', body: {
      "endDate": endDate.toUtc().toIso8601String(),
      "usageLimit": usageLimit,
      "serviceId": serviceId, 
      "imageUrl": imageUrl, 
    });
  }
  static Future<void> deleteVoucher(int id) async {
    await ApiClient.delete('/api/store-vouchers/$id');
  }
}