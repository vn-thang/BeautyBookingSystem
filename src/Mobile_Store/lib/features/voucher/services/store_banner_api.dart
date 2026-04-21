import '../../../core/network/api_client.dart';
import '../models/store_banner_model.dart';

class StoreBannerApi {
  static Future<List<StoreBannerModel>> getBanners() async {
    final json = await ApiClient.get('/api/my-store/banners');
    List data = json is List ? json : (json['data'] ?? []);
    return data.map((e) => StoreBannerModel.fromJson(e)).toList();
  }

  static Future<StoreBannerModel> addBanner({
    required String imageUrl,
    String? title,
    String? description,
    required int sortOrder,
  }) async {
    final json = await ApiClient.post('/api/my-store/banners', body: {
      "imageUrl": imageUrl,
      "title": title,
      "description": description,
      "sortOrder": sortOrder,
    });
    return StoreBannerModel.fromJson(json is Map<String, dynamic> ? json : json['data']);
  }

  static Future<bool> toggleStatus(int id) async {
    final json = await ApiClient.put('/api/my-store/banners/$id/toggle-status');
    return json['isActive'] ?? false; 
  }

  static Future<void> deleteBanner(int id) async {
    await ApiClient.delete('/api/my-store/banners/$id');
  }
}