import '../repositories/store_repository.dart';
import '../../data/models/store_model.dart';

class GetStoreById {
  final StoreRepository repository;
  GetStoreById(this.repository);

  Future<StoreModel> call(int id) {
    return repository.getStoreById(id);
  }
}