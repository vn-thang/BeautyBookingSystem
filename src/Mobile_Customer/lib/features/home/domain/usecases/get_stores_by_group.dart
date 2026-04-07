import '../repositories/store_repository.dart';
import '../../data/models/store_model.dart';

class GetStoresByGroup {
  final StoreRepository repository;
  GetStoresByGroup(this.repository);

  Future<List<StoreModel>> call(int groupId) {
    return repository.getStoresByGroup(groupId);
  }
}