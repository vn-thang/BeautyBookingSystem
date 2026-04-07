import '../repositories/store_repository.dart';
import '../../data/models/store_model.dart';

class GetStoresByCategory {
  final StoreRepository repository;
  GetStoresByCategory(this.repository);

  Future<List<StoreModel>> call(int categoryId) {
    return repository.getStoresByCategory(categoryId);
  }
}