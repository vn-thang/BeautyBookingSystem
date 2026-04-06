import 'package:intl/intl.dart'; 
import '../../../core/network/api_client.dart';
import '../models/store_dashboard_model.dart'; 

class DashboardService {
  static Future<StoreDashboardModel> getDashboardData({
    String? timeFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String url = '/api/store-dashboard';
      
      List<String> queryParams = [];
      
      if (timeFilter != null && timeFilter.isNotEmpty) {
        queryParams.add('timeFilter=$timeFilter');
      }

      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      
      if (startDate != null) {
        queryParams.add('startDate=${formatter.format(startDate)}');
      }
      
      if (endDate != null) {
        queryParams.add('endDate=${formatter.format(endDate)}');
      }

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      final response = await ApiClient.get(url);
      
      return StoreDashboardModel.fromJson(response as Map<String, dynamic>);
      
    } catch (e) {
      rethrow;
    }
  }
}