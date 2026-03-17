// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '../../../shared/token_storage.dart'; 
// import '../../../core/api_constants.dart'; 

// class StoreService {
//   static Future<bool> updateProfile(Map<String, dynamic> storeData) async {
//     try {
//       final token = await TokenStorage.getAccessToken(); 
      
//       final response = await http.put(
//         // Gọi thẳng từ ApiConstants
//         Uri.parse('${ApiConstants.baseUrl}/api/Stores/profile'), 
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token', 
//         },
//         body: jsonEncode(storeData),
//       );

//       if (response.statusCode == 200 || response.statusCode == 204) {
//         return true; 
//       } else {
//         debugPrint('Lỗi cập nhật: ${response.body}');
//         return false;
//       }
//     } catch (e) {
//       debugPrint('Lỗi kết nối: $e');
//       return false;
//     }
//   }
  
  
//   static Future<Map<String, dynamic>?> getProfileDetail() async {
//     try {
//       final token = await TokenStorage.getAccessToken();
      
//       final response = await http.get(
//         Uri.parse('${ApiConstants.baseUrl}/api/Stores/profile'), // API GET thông tin
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         return jsonDecode(response.body); // Trả về data cũ của shop
//       } else {
//         debugPrint('Lỗi tải profile: ${response.body}');
//         return null;
//       }
//     } catch (e) {
//       debugPrint('Lỗi kết nối: $e');
//       return null;
//     }
//   }
// }
// import '../../../core/network/api_client.dart';

// class StoreService {
//   // 1. Cập nhật hồ sơ
//   static Future<bool> updateProfile(Map<String, dynamic> storeData) async {
//     await ApiClient.put('/api/Stores/profile', body: storeData);
//     return true; 
//   }
  
//   // 2. Lấy chi tiết hồ sơ
//   static Future<Map<String, dynamic>> getProfileDetail() async {
//     final json = await ApiClient.get('/api/Stores/profile');
//     return json is Map<String, dynamic> ? json : json['data'];
//   }
// }

// file: lib/services/store_service.dart

import '../../../core/network/api_client.dart';
import '../models/store_profile.dart'; // Import model vào

class StoreService {
  // 1. Cập nhật hồ sơ (Truyền hẳn Object StoreProfile vào)
  static Future<bool> updateProfile(StoreProfile profile) async {
    // profile.toJson() tự động xử lý loại bỏ isActive và format đúng chuẩn
    await ApiClient.put('/api/Stores/profile', body: profile.toJson());
    return true; 
  }
  
  // 2. Lấy chi tiết hồ sơ (Trả về Object StoreProfile)
  static Future<StoreProfile> getProfileDetail() async {
    final response = await ApiClient.get('/api/Stores/profile');
    
    // Xử lý bóc tách data
    final dynamic json = response is Map<String, dynamic> && response.containsKey('data') 
        ? response['data'] 
        : response;

    return StoreProfile.fromJson(json);
  }
}