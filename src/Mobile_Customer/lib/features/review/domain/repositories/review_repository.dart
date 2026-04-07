import '../entities/review_entity.dart';

abstract class ReviewRepository {
  Future<List<ReviewEntity>> getMyReviews();
  Future<ReviewEntity> createReview({
    required int bookingId,
    required int rating,
    String? comment,
  });
}
