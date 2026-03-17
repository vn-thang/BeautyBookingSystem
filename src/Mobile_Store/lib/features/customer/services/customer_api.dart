import '../../../core/network/api_client.dart';
import '../models/customer_list_model.dart';
import '../models/customer_profile_model.dart';

class CustomerApi {
  // 1. Lấy danh sách khách hàng 
  static Future<List<CustomerListModel>> getCustomers(int storeId, {String? searchTerm}) async {
    String url = '/api/store/$storeId/customers';

    if (searchTerm != null && searchTerm.trim().isNotEmpty) {
      url += '?searchTerm=${Uri.encodeComponent(searchTerm.trim())}';
    }

    final json = await ApiClient.get(url);
    
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => CustomerListModel.fromJson(e)).toList();
  }

  static Future<CustomerProfileModel> getCustomerProfile(int storeId, int customerId) async {
    final json = await ApiClient.get('/api/store/$storeId/customers/$customerId');
    
    final data = json['data'] ?? json; 
    
    return CustomerProfileModel.fromJson(data);
  }
}