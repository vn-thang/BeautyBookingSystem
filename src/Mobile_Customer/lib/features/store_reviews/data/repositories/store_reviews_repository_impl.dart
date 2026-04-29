import '../../domain/entities/store_review_entity.dart';
import '../../domain/repositories/store_reviews_repository.dart';
import '../datasources/store_reviews_remote_data_source.dart';

class StoreReviewsRepositoryImpl implements StoreReviewsRepository {
  final StoreReviewsRemoteDataSource remoteDataSource;

  StoreReviewsRepositoryImpl(this.remoteDataSource);

  @override
  Future<PagedStoreReviewEntity> getStoreReviews({
    required int storeId,
    required int page,
    required int pageSize,
    int? rating,
    String sortBy = 'latest',
  }) async {
    final model = await remoteDataSource.getStoreReviews(
      storeId: storeId,
      page: page,
      pageSize: pageSize,
      rating: rating,
      sortBy: sortBy,
    );
    return model.toEntity();
  }

  @override
  Future<List<StoreReviewEntity>> getTopStoreReviews({
    required int storeId,
    required int take,
  }) async {
    final models = await remoteDataSource.getTopStoreReviews(
      storeId: storeId,
      take: take,
    );
    return models.map((e) => e.toEntity()).toList();
  }
}
