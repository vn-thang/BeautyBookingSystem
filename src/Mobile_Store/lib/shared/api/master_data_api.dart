import 'package:mobile_store/shared/models/simple_service_model.dart';

import '../../core/network/api_client.dart'; 
import '../models/simple_staff_model.dart'; 
class MasterDataApi {
  static Future<List<SimpleStaffModel>> getStaffsForFilter({bool onlyActive = true}) async {
    try {
      final json = await ApiClient.get('/api/StoreStaffs?onlyActive=$onlyActive');
      
      List data = json is List ? json : (json['data'] ?? []);
      
      return data.map((e) => SimpleStaffModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<SimpleServiceModel>> getServicesForDropdown() async {
    try {
      final json = await ApiClient.get('/api/StoreServices/dropdown-list');
      
      List data = json is List ? json : (json['data'] ?? []);
      
      return data.map((e) => SimpleServiceModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }
}