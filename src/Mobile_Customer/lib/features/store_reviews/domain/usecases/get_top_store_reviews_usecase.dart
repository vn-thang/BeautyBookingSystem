import '../entities/store_review_entity.dart';
import '../repositories/store_reviews_repository.dart';

class GetTopStoreReviewsUseCase {
  final StoreReviewsRepository repository;

  GetTopStoreReviewsUseCase(this.repository);

  Future<List<StoreReviewEntity>> call({
    required int storeId,
    int take = 5,
  }) {
    return repository.getTopStoreReviews(storeId: storeId, take: take);
  }
}
