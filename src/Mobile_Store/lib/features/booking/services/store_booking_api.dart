import '../../../core/network/api_client.dart'; 
import '../models/store_booking_model.dart';

class StoreBookingApi {
  // 1. Lấy danh sách booking
  static Future<List<StoreBookingListModel>> getBookings({String? status}) async {
    final queryParam = status != null ? '?status=$status' : '';
    
    final json = await ApiClient.get('/api/StoreBookings$queryParam');
    
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => StoreBookingListModel.fromJson(e)).toList();
  }

  // 2. Lấy chi tiết booking
  static Future<StoreBookingDetailModel> getBookingDetail(int id) async {
    final json = await ApiClient.get('/api/StoreBookings/$id');
    return StoreBookingDetailModel.fromJson(json is Map<String, dynamic> ? json : json['data']);
  }

  // 3. Lấy nhân viên rảnh
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

  // 4. Gán nhân viên và xác nhận
  static Future<bool> assignStaff(int bookingId, List<Map<String, int>> assignments) async {
    await ApiClient.put(
      '/api/StoreBookings/$bookingId/assign-staff',
      body: { "assignments": assignments },
    );
    return true;
  }

  // 5. Cập nhật trạng thái (Hủy / Hoàn thành)
  static Future<bool> updateStatus(int bookingId, String status, {String? cancelReason}) async {
    await ApiClient.put(
      '/api/StoreBookings/$bookingId/status',
      body: { "status": status, "cancelReason": cancelReason },
    );
    return true;
  }
}