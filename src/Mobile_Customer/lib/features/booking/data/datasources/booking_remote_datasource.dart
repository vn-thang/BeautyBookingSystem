import 'package:dio/dio.dart';
import '../models/booking_request_model.dart';
import '../models/available_staff_model.dart';

abstract class BookingRemoteDataSource {
  Future<void> createBooking(BookingRequestModel request);
  Future<List<AvailableStaffModel>> getAvailableStaff({
    required int storeId,
    required int serviceId,
    required DateTime appointmentDate,
    required String startTime,
  });
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final Dio dio;

  BookingRemoteDataSourceImpl(this.dio);

  @override
  Future<void> createBooking(BookingRequestModel request) async {
    await dio.post('bookings', data: request.toJson());
  }

  @override
  Future<List<AvailableStaffModel>> getAvailableStaff({
    required int storeId,
    required int serviceId,
    required DateTime appointmentDate,
    required String startTime,
  }) async {
    final body = {
      "storeId": storeId,
      "serviceId": serviceId,
      // gửi date chỉ phần ngày như "2026-03-20"
      "appointmentDate": appointmentDate.toIso8601String().split('T').first,
      // gửi time như "13:00:00" -> startTime param ở dạng string
      "startTime": startTime,
    };

    final response = await dio.post('bookings/available-staff', data: body);
    final data = response.data;
    // API trả list JSON hoặc object list
    if (data is List) {
      return (data as List)
          .map((e) => AvailableStaffModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (data is Map && data['availableStaffs'] is List) {
      return (data['availableStaffs'] as List)
          .map((e) => AvailableStaffModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return <AvailableStaffModel>[];
  }
}