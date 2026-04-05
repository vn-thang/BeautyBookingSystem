import '../entities/search_history_entity.dart';
import '../repositories/search_history_repository.dart';

class GetRecentSearchHistories {
  final SearchHistoryRepository repository;

  GetRecentSearchHistories(this.repository);

  Future<List<SearchHistoryEntity>> call() {
    return repository.getRecent();
  }
}
