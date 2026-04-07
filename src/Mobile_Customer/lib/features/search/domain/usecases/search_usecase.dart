import '../entities/search_store.dart';
import '../repositories/search_repository.dart';

class SearchUseCase {
  final SearchRepository repository;

  SearchUseCase(this.repository);

  Future<List<SearchStore>> call({
    String? keyword,
    String? location,
    double? userLat,
    double? userLng,
    required String sortBy,
    int? minRating,
    double? minPrice,
    double? maxPrice,
  }) {
    return repository.search(
      keyword: keyword,
      location: location,
      userLat: userLat,
      userLng: userLng,
      sortBy: sortBy,
      minRating: minRating,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }
}
