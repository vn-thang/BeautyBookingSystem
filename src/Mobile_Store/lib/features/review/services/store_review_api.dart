import '../../../../core/network/api_client.dart'; 
import '../models/store_review_model.dart';

class StoreReviewApi {
  static Future<List<StoreReviewModel>> getReviews({int? rating, bool? hasReplied}) async {
    List<String> queryParams = [];
    if (rating != null) queryParams.add('rating=$rating');
    if (hasReplied != null) queryParams.add('hasReplied=$hasReplied');
    
    String queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
    
    final json = await ApiClient.get('/api/StoreReviews$queryString');
    List data = json is List ? json : (json['data'] ?? []);
    
    return data.map((e) => StoreReviewModel.fromJson(e)).toList();
  }

  static Future<StoreReviewModel> getReviewById(int id) async {
    final json = await ApiClient.get('/api/StoreReviews/$id');
    return StoreReviewModel.fromJson(json is Map<String, dynamic> ? json : json['data']);
  }

  static Future<void> replyReview({required int id, required String replyContent}) async {
    await ApiClient.put('/api/StoreReviews/$id/reply', body: {
      "reply": replyContent,
    });
  }
}