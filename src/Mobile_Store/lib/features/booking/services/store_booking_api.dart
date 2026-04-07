import 'package:intl/intl.dart';

import '../../../core/network/api_client.dart'; 
import '../models/store_booking_model.dart';
import '../models/booking_bill_model.dart';

class StoreBookingApi {
  static Future<List<StoreBookingListModel>> getBookings({
    String? status,
    int? staffId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    List<String> queryParams = [];

    if (status != null && status.isNotEmpty) {
      queryParams.add('status=$status');
    }
    if (startDate != null) {
      queryParams.add('startDate=${DateFormat('yyyy-MM-dd').format(startDate)}');
    }
    if (endDate != null) {
      queryParams.add('endDate=${DateFormat('yyyy-MM-dd').format(endDate)}');
    }
  if (staffId != null) {
      queryParams.add('staffId=$staffId'); 
    }
    final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
    
    final json = await ApiClient.get('/api/StoreBookings$queryString');
    
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => StoreBookingListModel.fromJson(e)).toList();
  }

  static Future<StoreBookingDetailModel> getBookingDetail(int id) async {
    final json = await ApiClient.get('/api/StoreBookings/$id');
    return StoreBookingDetailModel.fromJson(json is Map<String, dynamic> ? json : json['data']);
  }

  static Future<List<AvailableStaffModel>> getAvailableStaffs({
    required DateTime date,
    required String startTime,
    required String endTime,
  }) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final json = await ApiClient.get(
      '/api/StoreBookings/available-staffs?date=$dateStr&startTime=$startTime&endTime=$endTime'
    );
    
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => AvailableStaffModel.fromJson(e)).toList();
  }

  static Future<bool> assignStaff(int bookingId, List<Map<String, int>> assignments) async {
    await ApiClient.put(
      '/api/StoreBookings/$bookingId/assign-staff',
      body: { "assignments": assignments },
    );
    return true;
  }

  static Future<bool> updateStatus(int bookingId, String status, {String? cancelReason}) async {
    await ApiClient.put(
      '/api/StoreBookings/$bookingId/status',
      body: { "status": status, "cancelReason": cancelReason },
    );
    return true;
  }

  static Future<BookingBillModel> getBillDetail(int bookingId) async {
    final response = await ApiClient.get('/api/store/bookings/$bookingId/bill');
    final data = response['data'] ?? response['Data'];
    
    return BookingBillModel.fromJson(data);
  }
}