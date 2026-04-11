import '../../domain/repositories/customer_favorite_repository.dart';
import '../datasources/customer_favorite_remote_datasource.dart';

class CustomerFavoriteRepositoryImpl implements CustomerFavoriteRepository {
  final CustomerFavoriteRemoteDataSource remoteDataSource;

  CustomerFavoriteRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> favoriteStore(int storeId) {
    return remoteDataSource.favoriteStore(storeId);
  }

  @override
  Future<void> unfavoriteStore(int storeId) {
    return remoteDataSource.unfavoriteStore(storeId);
  }

  @override
  Future<void> favoriteService(int serviceId) {
    return remoteDataSource.favoriteService(serviceId);
  }

  @override
  Future<void> unfavoriteService(int serviceId) {
    return remoteDataSource.unfavoriteService(serviceId);
  }
}
