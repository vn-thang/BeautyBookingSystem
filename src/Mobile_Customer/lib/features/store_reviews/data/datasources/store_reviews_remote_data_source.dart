import 'package:dio/dio.dart';

import '../models/store_review_model.dart';

abstract class StoreReviewsRemoteDataSource {
  Future<PagedStoreReviewModel> getStoreReviews({
    required int storeId,
    required int page,
    required int pageSize,
    int? rating,
    String sortBy,
  });

  Future<List<StoreReviewModel>> getTopStoreReviews({
    required int storeId,
    required int take,
  });
}

class StoreReviewsRemoteDataSourceImpl implements StoreReviewsRemoteDataSource {
  final Dio dio;

  StoreReviewsRemoteDataSourceImpl(this.dio);

  @override
  Future<PagedStoreReviewModel> getStoreReviews({
    required int storeId,
    required int page,
    required int pageSize,
    int? rating,
    String sortBy = 'latest',
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      'sortBy': sortBy,
    };

    if (rating != null) {
      query['rating'] = rating;
    }

    final res = await dio.get(
      'reviews/store/$storeId',
      queryParameters: query,
    );

    return PagedStoreReviewModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<List<StoreReviewModel>> getTopStoreReviews({
    required int storeId,
    required int take,
  }) async {
    final res = await dio.get(
      'reviews/store/$storeId/top',
      queryParameters: {'take': take},
    );

    final data = res.data as List<dynamic>;
    return data
        .map((e) => StoreReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
