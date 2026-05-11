import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_store/features/booking/models/store_createbooking_model.dart';

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
  static Future<void> markNoShow({required int bookingId}) async {
    await ApiClient.put('/api/StoreBookings/$bookingId/no-show'); 
  }
static Future<List<TimeSlotModel>> getAvailableTimeSlots({
  required DateTime date,
  required int totalDurationMinutes,
}) async {
  try {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final json = await ApiClient.get(
      '/api/StoreBookings/available-time-slots?date=$dateStr&totalDurationMinutes=$totalDurationMinutes'
    );
    
    final List<dynamic> data = (json is List) 
        ? json 
        : (json is Map<String, dynamic> && json['data'] != null ? json['data'] : []);
        
    return data.map((e) => TimeSlotModel.fromJson(e)).toList();
  } catch (e) {
    debugPrint("Lỗi getAvailableTimeSlots: $e");
    throw Exception('Không thể tải khung giờ. Vui lòng thử lại.');
  }
}
static Future<BookingResponseDto> createStoreBooking(CreateStoreBookingRequest request) async {
  try {
    final json = await ApiClient.post(
      '/api/StoreBookings/store-booking',
      body: request.toJson(),
    );
    
    final Map<String, dynamic> responseData = (json is Map<String, dynamic> && json.containsKey('data')) 
        ? json['data'] 
        : json as Map<String, dynamic>; 
        
    return BookingResponseDto.fromJson(responseData);
  } catch (e) {
    debugPrint("Lỗi createStoreBooking: $e");
    rethrow; 
  }
}
}