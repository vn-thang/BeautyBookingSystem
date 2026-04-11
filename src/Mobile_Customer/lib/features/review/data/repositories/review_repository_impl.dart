import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_datasource.dart';
import '../models/create_review_request_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remote;

  ReviewRepositoryImpl(this.remote);

  @override
  Future<List<ReviewEntity>> getMyReviews() {
    return remote.getMyReviews();
  }

  @override
  Future<ReviewEntity> createReview({
    required int bookingId,
    required int rating,
    String? comment,
  }) {
    return remote.createReview(
      CreateReviewRequestModel(
        bookingId: bookingId,
        rating: rating,
        comment: comment,
      ),
    );
  }
}
