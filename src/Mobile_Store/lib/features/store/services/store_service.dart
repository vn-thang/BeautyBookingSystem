import '../../../core/network/api_client.dart';
import '../models/store_profile.dart';

class StoreService {
  static Future<bool> updateProfile(StoreProfile profile) async {
    await ApiClient.put('/api/Stores/profile', body: profile.toJson());
    return true; 
  }
  
  static Future<StoreProfile> getProfileDetail() async {
    final response = await ApiClient.get('/api/Stores/profile');
    
    final dynamic json = response is Map<String, dynamic> && response.containsKey('data') 
        ? response['data'] 
        : response;

    return StoreProfile.fromJson(json);
  }
}