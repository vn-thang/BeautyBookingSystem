import '../entities/search_history_entity.dart';
import '../repositories/search_history_repository.dart';

class DeleteSearchHistory {
  final SearchHistoryRepository repository;

  DeleteSearchHistory(this.repository);

  Future<List<SearchHistoryEntity>> call(int id) {
    return repository.delete(id);
  }
}
