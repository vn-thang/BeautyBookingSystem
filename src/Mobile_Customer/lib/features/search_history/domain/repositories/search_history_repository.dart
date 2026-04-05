import '../entities/search_history_entity.dart';

abstract class SearchHistoryRepository {
  Future<List<SearchHistoryEntity>> getRecent();
  Future<List<SearchHistoryEntity>> record(String keyword);
  Future<List<SearchHistoryEntity>> delete(int id);
}
