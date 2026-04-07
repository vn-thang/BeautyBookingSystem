import '../repositories/customer_favorite_repository.dart';

class UnfavoriteStoreUseCase {
  final CustomerFavoriteRepository repository;

  UnfavoriteStoreUseCase(this.repository);

  Future<void> call(int storeId) {
    return repository.unfavoriteStore(storeId);
  }
}
