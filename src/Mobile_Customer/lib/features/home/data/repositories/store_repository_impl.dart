import '../../domain/repositories/store_repository.dart';
import '../datasources/home_remote_datasource.dart';
import '../../data/models/store_model.dart';

class StoreRepositoryImpl implements StoreRepository {
  final HomeRemoteDataSource remote;
  StoreRepositoryImpl(this.remote);

  @override
  Future<List<StoreModel>> getStoresByCategory(int categoryId) {
    return remote.getStoresByCategory(categoryId);
  }

  @override
  Future<List<StoreModel>> getStoresByGroup(int groupId) {
  return remote.getStoresByGroup(groupId);
  }

  @override
  Future<StoreModel> getStoreById(int id) {
    return remote.getStoreById(id);
  }
}