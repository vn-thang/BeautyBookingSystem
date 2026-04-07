import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

class CreateReview {
  final ReviewRepository repository;

  CreateReview(this.repository);

  Future<ReviewEntity> call({
    required int bookingId,
    required int rating,
    String? comment,
  }) {
    return repository.createReview(
      bookingId: bookingId,
      rating: rating,
      comment: comment,
    );
  }
}
