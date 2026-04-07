import '../repositories/customer_favorite_repository.dart';

class FavoriteStoreUseCase {
  final CustomerFavoriteRepository repository;

  FavoriteStoreUseCase(this.repository);

  Future<void> call(int storeId) {
    return repository.favoriteStore(storeId);
  }
}
