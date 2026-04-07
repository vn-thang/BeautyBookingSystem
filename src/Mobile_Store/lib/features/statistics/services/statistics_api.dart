import 'dart:typed_data';
import '../../../core/network/api_client.dart';
import '../models/revenue_chart_item_model.dart';
import '../models/review_statistics_model.dart';
import '../models/top_performance_item_model.dart';

class StatisticsApi {
  static String _buildQuery(DateTime? startDate, DateTime? endDate) {
    List<String> queryParams = [];
    if (startDate != null) {
      queryParams.add('startDate=${startDate.toIso8601String()}');
    }
    if (endDate != null) {
      queryParams.add('endDate=${endDate.toIso8601String()}');
    }
    return queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
  }

  static Future<List<RevenueChartItemModel>> getRevenueChart({DateTime? startDate, DateTime? endDate}) async {
    final query = _buildQuery(startDate, endDate);
    final json = await ApiClient.get('/api/store-statistics/revenue-chart$query');
    
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => RevenueChartItemModel.fromJson(e)).toList();
  }

  static Future<List<TopPerformanceItemModel>> getTopServices({DateTime? startDate, DateTime? endDate, int top = 5}) async {
    String query = _buildQuery(startDate, endDate);
    query += query.isEmpty ? '?top=$top' : '&top=$top'; 

    final json = await ApiClient.get('/api/store-statistics/top-services$query');
    
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => TopPerformanceItemModel.fromJson(e)).toList();
  }

  static Future<List<TopPerformanceItemModel>> getTopStaffs({DateTime? startDate, DateTime? endDate, int top = 5}) async {
    String query = _buildQuery(startDate, endDate);
    query += query.isEmpty ? '?top=$top' : '&top=$top';

    final json = await ApiClient.get('/api/store-statistics/top-staffs$query');
    
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => TopPerformanceItemModel.fromJson(e)).toList();
  }

  static Future<List<TopPerformanceItemModel>> getTopCustomers({DateTime? startDate, DateTime? endDate, int top = 5}) async {
    String query = _buildQuery(startDate, endDate);
    query += query.isEmpty ? '?top=$top' : '&top=$top';

    final json = await ApiClient.get('/api/store-statistics/top-customers$query');
    
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => TopPerformanceItemModel.fromJson(e)).toList();
  }

  static Future<ReviewStatisticsModel> getReviewStatistics({DateTime? startDate, DateTime? endDate}) async {
    String path = '/api/store-statistics/reviews';
    List<String> queryParams = [];

    if (startDate != null) {
      queryParams.add('startDate=${startDate.toIso8601String()}');
    }
    if (endDate != null) {
      queryParams.add('endDate=${endDate.toIso8601String()}');
    }

    if (queryParams.isNotEmpty) {
      path += '?${queryParams.join('&')}';
    }

    final json = await ApiClient.get(path);
    
    return ReviewStatisticsModel.fromJson(json['data'] ?? json);
  }
  static Future<Uint8List> exportRevenueExcel({DateTime? startDate, DateTime? endDate}) async {
    final query = _buildQuery(startDate, endDate);
    final endpoint = '/api/store-statistics/export-revenue$query';

    try {
      final List<int> bytesData = await ApiClient.downloadFile(endpoint);
      return Uint8List.fromList(bytesData);

    } catch (e) {
      throw Exception(e.toString().replaceAll("Exception: ", ""));
    }
  }
}