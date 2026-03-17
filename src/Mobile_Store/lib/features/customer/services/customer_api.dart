import '../../../core/network/api_client.dart';
import '../models/customer_list_model.dart';
import '../models/customer_profile_model.dart';

class CustomerApi {
  // 1. Lấy danh sách khách hàng (Có phân trang/tìm kiếm nếu cần)
  
  static Future<List<CustomerListModel>> getCustomers(int storeId, {String? searchTerm}) async {
    String url = '/api/store/$storeId/customers';

    if (searchTerm != null && searchTerm.trim().isNotEmpty) {
      // Encode URL để tránh lỗi nếu searchTerm có dấu cách hoặc ký tự đặc biệt
      url += '?searchTerm=${Uri.encodeComponent(searchTerm.trim())}';
    }

    final json = await ApiClient.get(url);
    
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => CustomerListModel.fromJson(e)).toList();
  }

  // 2. Lấy hồ sơ 360 độ (Chi tiết của 1 khách hàng)
  static Future<CustomerProfileModel> getCustomerProfile(int storeId, int customerId) async {
    final json = await ApiClient.get('/api/store/$storeId/customers/$customerId');
    
    // API C# thường bọc kết quả trong biến 'data' (theo response bạn đã setup)
    final data = json['data'] ?? json; 
    
    return CustomerProfileModel.fromJson(data);
  }
}