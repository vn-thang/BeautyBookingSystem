import '../entities/search_store.dart';

abstract class SearchRepository {
  Future<List<SearchStore>> search({
    String? keyword,
    String? location,
    double? userLat,
    double? userLng,
    required String sortBy,
    int? minRating,
    double? minPrice,
    double? maxPrice,
  });
}
