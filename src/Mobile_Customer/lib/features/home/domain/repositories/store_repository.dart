import '../../data/models/store_model.dart';

abstract class StoreRepository {
  Future<List<StoreModel>> getStoresByCategory(int categoryId);
  Future<List<StoreModel>> getStoresByGroup(int groupId);
  Future<StoreModel> getStoreById(int id);
}