import '../entities/store_review_entity.dart';
import '../repositories/store_reviews_repository.dart';

class GetStoreReviewsUseCase {
  final StoreReviewsRepository repository;

  GetStoreReviewsUseCase(this.repository);

  Future<PagedStoreReviewEntity> call({
    required int storeId,
    int page = 1,
    int pageSize = 10,
  }) {
    return repository.getStoreReviews(
      storeId: storeId,
      page: page,
      pageSize: pageSize,
    );
  }
}
