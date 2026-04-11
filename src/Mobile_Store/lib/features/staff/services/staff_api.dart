import 'package:mobile_store/features/staff/models/staff_leave_model.dart';
import 'package:mobile_store/features/staff/models/staff_schedule_model.dart';

import '../../../core/network/api_client.dart';
import '../models/staff_model.dart';

class StaffApi {
  static Future<List<StaffModel>> getStaffs({bool onlyActive = false}) async {
    final json = await ApiClient.get('/api/StoreStaffs?onlyActive=$onlyActive');
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => StaffModel.fromJson(e)).toList();
  }

  static Future<void> createStaff({required String fullName, required String position, String? avatarUrl}) async {
    await ApiClient.post('/api/StoreStaffs', body: {
      "fullName": fullName,
      "position": position,
      "avatarUrl": (avatarUrl?.trim().isEmpty ?? true) ? null : avatarUrl,
    });
  }

  static Future<void> updateStaff({
    required int id, required String fullName, required String position,
    String? avatarUrl, required bool isActive,
  }) async {
    await ApiClient.put('/api/StoreStaffs/$id', body: {
      "fullName": fullName,
      "position": position,
      "avatarUrl": (avatarUrl?.trim().isEmpty ?? true) ? null : avatarUrl,
      "isActive": isActive,
    });
  }

  static Future<void> deleteStaff(int id) async {
    await ApiClient.delete('/api/StoreStaffs/$id');
  }

  static Future<List<StaffScheduleModel>> getSchedules(int staffId) async {
    final json = await ApiClient.get('/api/StoreStaffs/$staffId/schedules');
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => StaffScheduleModel.fromJson(e)).toList();
  }

  static Future<void> updateSchedules(int staffId, List<StaffScheduleModel> schedules) async {
    await ApiClient.put('/api/StoreStaffs/$staffId/schedules', body: {
      "schedules": schedules.map((e) => e.toJson()).toList()
    });
  }

  static Future<List<StaffLeaveModel>> getLeaves(int staffId) async {
    final json = await ApiClient.get('/api/StoreStaffs/$staffId/leaves');
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => StaffLeaveModel.fromJson(e)).toList();
  }
  static Future<void> createLeave({
    required int staffId, 
    required DateTime fromDate, 
    required DateTime toDate, 
    String? reason
  }) async {
    await ApiClient.post('/api/StoreStaffs/$staffId/leaves', body: {
      "fromDate": fromDate.toIso8601String(),
      "toDate": toDate.toIso8601String(),
      "reason": reason,
    });
  }
  static Future<void> deleteLeave(int staffId, int leaveId) async {
    await ApiClient.delete('/api/StoreStaffs/$staffId/leaves/$leaveId');
  }
}