import '../../domain/entities/search_store.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remote;

  SearchRepositoryImpl(this.remote);

  @override
  Future<List<SearchStore>> search({
    String? keyword,
    String? location,
    double? userLat,
    double? userLng,
    required String sortBy,
    int? minRating,
    double? minPrice,
    double? maxPrice,
  }) async {
    final models = await remote.search(
      keyword: keyword,
      location: location,
      userLat: userLat,
      userLng: userLng,
      sortBy: sortBy,
      minRating: minRating,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );

    return models.map((e) => e.toEntity()).toList();
  }
}
