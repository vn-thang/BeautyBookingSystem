import '../repositories/customer_favorite_repository.dart';

class UnfavoriteServiceUseCase {
  final CustomerFavoriteRepository repository;

  UnfavoriteServiceUseCase(this.repository);

  Future<void> call(int serviceId) {
    return repository.unfavoriteService(serviceId);
  }
}
