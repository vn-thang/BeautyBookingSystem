import '../../../core/network/api_client.dart';
import 'package:flutter/material.dart';
import '../models/store_profile.dart';

class StoreService {
  static Future<bool> updateProfile(StoreProfile profile) async {
    try {
      await ApiClient.put('/api/store/my-store/profile', body: profile.toJson());
      return true; 
    } catch (e) {
      debugPrint("Lỗi khi cập nhật cửa hàng: $e");
      rethrow; 
    }
  }
  
  static Future<StoreProfile> getProfileDetail() async {
    final response = await ApiClient.get('/api/store/my-store/profile');
    
    final dynamic json = response is Map<String, dynamic> && response.containsKey('data') 
        ? response['data'] 
        : response;

    return StoreProfile.fromJson(json);
  }
}