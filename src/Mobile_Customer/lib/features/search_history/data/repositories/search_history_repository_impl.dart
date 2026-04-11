import '../../domain/entities/search_history_entity.dart';
import '../../domain/repositories/search_history_repository.dart';
import '../datasources/search_history_remote_datasource.dart';

class SearchHistoryRepositoryImpl implements SearchHistoryRepository {
  final SearchHistoryRemoteDataSource remoteDataSource;

  SearchHistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SearchHistoryEntity>> getRecent() {
    return remoteDataSource.getRecent();
  }

  @override
  Future<List<SearchHistoryEntity>> record(String keyword) {
    return remoteDataSource.record(keyword);
  }

  @override
  Future<List<SearchHistoryEntity>> delete(int id) {
    return remoteDataSource.delete(id);
  }
}
