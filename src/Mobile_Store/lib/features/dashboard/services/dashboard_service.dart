// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// // Giữ nguyên đường dẫn import giống hệt store_service của bạn
// import '../../../shared/token_storage.dart'; 
// import '../../../core/api_constants.dart'; 

// class DashboardService {
//   /// Lấy dữ liệu thống kê cho Dashboard
//   static Future<Map<String, dynamic>> getDashboardData() async {
//     try {
//       final token = await TokenStorage.getAccessToken(); 
      
//       final response = await http.get(
//         // Ghép BaseUrl với endpoint mà bạn đã cung cấp
//         Uri.parse('${ApiConstants.baseUrl}/api/store-dashboard'), 
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token', 
//         },
//       );

//       // Nếu API trả về thành công (200 OK)
//       if (response.statusCode == 200) {
//         // Parse chuỗi JSON thành Map để UI dễ dàng đọc dữ liệu
//         final Map<String, dynamic> data = jsonDecode(response.body);
//         return data; 
//       } else {
//         // Log lỗi ra console để dev dễ debug
//         debugPrint('Lỗi tải Dashboard: Mã ${response.statusCode} - ${response.body}');
//         // Ném ra lỗi để bên UI bắt được (vào khối catch) và hiển thị thông báo cho người dùng
//         throw Exception('Không thể tải dữ liệu (Mã lỗi: ${response.statusCode})');
//       }
//     } catch (e) {
//       debugPrint('Lỗi kết nối Dashboard: $e');
//       throw Exception('Lỗi kết nối đến máy chủ. Vui lòng kiểm tra mạng!');
//     }
//   }
// }
// import '../../../core/network/api_client.dart';
// import '../models/store_dashboard_model.dart'; 

// class DashboardService {
//   /// Lấy dữ liệu thống kê cho Dashboard
//   /// Truyền [timeFilter] (today, week, month, year, all) để lọc theo thời gian.
//   static Future<StoreDashboardModel> getDashboardData({String? timeFilter}) async {
//     try {
//       // 1. Chuẩn bị URL
//       String url = '/api/store-dashboard';
      
//       // Nếu có truyền filter (vd: 'today'), thì nối thêm vào URL
//       if (timeFilter != null && timeFilter.isNotEmpty) {
//         url += '?timeFilter=$timeFilter';
//       }

//       // 2. Gọi API
//       final response = await ApiClient.get(url);
      
//       // 3. Parse dữ liệu Map sang Model và trả về
//       return StoreDashboardModel.fromJson(response as Map<String, dynamic>);
      
//     } catch (e) {
//       // Bắt lỗi từ ApiClient đẩy lên UI
//       rethrow;
//     }
//   }
// }

import 'package:intl/intl.dart'; // Import thêm intl để format ngày tháng gửi lên API
import '../../../core/network/api_client.dart';
import '../models/store_dashboard_model.dart'; 

class DashboardService {
  /// Lấy dữ liệu thống kê cho Dashboard
  /// Truyền [timeFilter] (today, week, month, custom) để lọc theo thời gian.
  /// Nếu [timeFilter] là 'custom', truyền thêm [startDate] và [endDate].
  static Future<StoreDashboardModel> getDashboardData({
    String? timeFilter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // 1. Chuẩn bị URL cơ bản
      String url = '/api/store-dashboard';
      
      // Tạo một danh sách chứa các tham số (Query Parameters)
      List<String> queryParams = [];
      
      // Thêm tham số timeFilter
      if (timeFilter != null && timeFilter.isNotEmpty) {
        queryParams.add('timeFilter=$timeFilter');
      }

      // Thêm tham số startDate và endDate nếu có (Định dạng yyyy-MM-dd)
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      
      if (startDate != null) {
        queryParams.add('startDate=${formatter.format(startDate)}');
      }
      
      if (endDate != null) {
        queryParams.add('endDate=${formatter.format(endDate)}');
      }

      // Nếu có tham số nào, nối chúng vào URL với dấu '?' và '&'
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      // 2. Gọi API (Lúc này URL sẽ có dạng: /api/store-dashboard?timeFilter=custom&startDate=2024-03-01&endDate=2024-03-14)
      final response = await ApiClient.get(url);
      
      // 3. Parse dữ liệu Map sang Model và trả về
      return StoreDashboardModel.fromJson(response as Map<String, dynamic>);
      
    } catch (e) {
      // Bắt lỗi từ ApiClient đẩy lên UI
      rethrow;
    }
  }
}