import '../../../core/network/api_client.dart';
import '../models/store_payment_model.dart';

class StorePaymentApi {
  static Future<List<StorePaymentModel>> getPayments() async {
    final json = await ApiClient.get('/api/StorePayments');
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => StorePaymentModel.fromJson(e)).toList();
  }

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

  static Future<bool> refundPayment(int id) async {
    await ApiClient.put('/api/StorePayments/$id/refund');
    return true;
  }
}