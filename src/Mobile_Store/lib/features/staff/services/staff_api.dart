import '../../../core/network/api_client.dart';
import '../models/staff_model.dart';

class StaffApi {
  static Future<List<StaffModel>> getStaffs({bool onlyActive = false}) async {
    final json = await ApiClient.get('/api/Staffs?onlyActive=$onlyActive');
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => StaffModel.fromJson(e)).toList();
  }

  static Future<void> createStaff({required String fullName, required String position, String? avatarUrl}) async {
    await ApiClient.post('/api/Staffs', body: {
      "fullName": fullName,
      "position": position,
      "avatarUrl": (avatarUrl?.trim().isEmpty ?? true) ? null : avatarUrl,
    });
  }

  static Future<void> updateStaff({
    required int id, required String fullName, required String position,
    String? avatarUrl, required bool isActive,
  }) async {
    await ApiClient.put('/api/Staffs/$id', body: {
      "fullName": fullName,
      "position": position,
      "avatarUrl": (avatarUrl?.trim().isEmpty ?? true) ? null : avatarUrl,
      "isActive": isActive,
    });
  }

  static Future<void> deleteStaff(int id) async {
    await ApiClient.delete('/api/Staffs/$id');
  }
}