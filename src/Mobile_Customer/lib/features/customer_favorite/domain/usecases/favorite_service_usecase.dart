import '../repositories/customer_favorite_repository.dart';

class FavoriteServiceUseCase {
  final CustomerFavoriteRepository repository;

  FavoriteServiceUseCase(this.repository);

  Future<void> call(int serviceId) {
    return repository.favoriteService(serviceId);
  }
}
