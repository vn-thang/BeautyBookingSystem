import 'package:dio/dio.dart';
import '../models/create_review_request_model.dart';
import '../models/review_model.dart';

class ReviewRemoteDataSource {
  final Dio dio;

  ReviewRemoteDataSource(this.dio);

  Future<List<ReviewModel>> getMyReviews() async {
    final resp = await dio.get('reviews/my-reviews');

    final data = resp.data;
    final List items = data is List
        ? data
        : (data is Map && data['data'] is List)
            ? data['data']
            : <dynamic>[];

    return items
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ReviewModel> createReview(CreateReviewRequestModel request) async {
    final resp = await dio.post(
      'reviews',
      data: request.toJson(),
    );

    return ReviewModel.fromJson(resp.data as Map<String, dynamic>);
  }
}
