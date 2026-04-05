import '../entities/review_entity.dart';
import '../repositories/review_repository.dart';

class GetMyReviews {
  final ReviewRepository repository;

  GetMyReviews(this.repository);

  Future<List<ReviewEntity>> call() {
    return repository.getMyReviews();
  }
}
