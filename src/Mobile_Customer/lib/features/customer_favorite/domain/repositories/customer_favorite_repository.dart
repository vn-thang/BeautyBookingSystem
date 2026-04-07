abstract class CustomerFavoriteRepository {
  Future<void> favoriteStore(int storeId);
  Future<void> unfavoriteStore(int storeId);

  Future<void> favoriteService(int serviceId);
  Future<void> unfavoriteService(int serviceId);
}
