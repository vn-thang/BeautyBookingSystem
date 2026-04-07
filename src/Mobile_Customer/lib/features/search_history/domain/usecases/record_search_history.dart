import '../entities/search_history_entity.dart';
import '../repositories/search_history_repository.dart';

class RecordSearchHistory {
  final SearchHistoryRepository repository;

  RecordSearchHistory(this.repository);

  Future<List<SearchHistoryEntity>> call(String keyword) {
    return repository.record(keyword);
  }
}
