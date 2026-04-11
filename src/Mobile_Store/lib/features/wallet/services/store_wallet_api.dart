import '../../../core/network/api_client.dart';
import '../models/wallet_transaction_model.dart';

class StoreWalletApi {
  static Future<WalletBalanceModel> getBalance() async {
    final json = await ApiClient.get('/api/store/wallet/balance');
    return WalletBalanceModel.fromJson(json);
  }

  static Future<WalletDashboardModel> getDashboard({int? month, int? year}) async {
    String url = '/api/store/wallet/dashboard';
  
    List<String> queryParams = [];
    if (month != null) queryParams.add('month=$month');
    if (year != null) queryParams.add('year=$year');
    
    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    final json = await ApiClient.get(url);
    return WalletDashboardModel.fromJson(json);
  }

  static Future<List<WalletTransactionModel>> getTransactions({
    int pageIndex = 1, 
    int pageSize = 50,
    int? month,
    int? year,
    int? type,
  }) async {
    String url = '/api/store/wallet/history?pageIndex=$pageIndex&pageSize=$pageSize';
    
    if (month != null) url += '&month=$month';
    if (year != null) url += '&year=$year';
    if (type != null) url += '&type=$type';

    final json = await ApiClient.get(url);
    
    List data = json['items'] ?? []; 
    return data.map((e) => WalletTransactionModel.fromJson(e)).toList();
  }
  static Future<String?> requestTopUp(double amount) async {
    final bodyData = {"amount": amount};
    final res = await ApiClient.post(
      '/api/store/wallet/create-topup-url', 
      body: bodyData,
    );
    return res['paymentUrl']; 
  }

  static Future<void> requestWithdraw(double amount) async {
    final bodyData = {
      "amount": amount
    };
    await ApiClient.post(
      '/api/store/wallet/withdrawals', 
      body: bodyData,
    );
  }
}