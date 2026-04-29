import '../entities/store_review_entity.dart';

abstract class StoreReviewsRepository {
  Future<PagedStoreReviewEntity> getStoreReviews({
    required int storeId,
    required int page,
    required int pageSize,
    int? rating,
    String sortBy,
  });

  Future<List<StoreReviewEntity>> getTopStoreReviews({
    required int storeId,
    required int take,
  });
}
