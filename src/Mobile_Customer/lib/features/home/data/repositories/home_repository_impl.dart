import '../../domain/entities/favorite_service.dart';
import '../../domain/entities/favorite_store.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';
import '../models/home_response_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remote;

  HomeRepositoryImpl(this.remote);

  @override
  Future<HomeData> getHomeData(double lat, double lon) async {
    final HomeResponseModel remoteHome = await remote.getHome(lat, lon);

    final categories = remoteHome.categories.map((e) => e.toEntity()).toList();
    final serviceGroups =
        remoteHome.serviceGroups.map((e) => e.toEntity()).toList();

    final nearbyStores =
        remoteHome.nearbyStores.map((e) => e.toEntity()).toList();

    final topRatedStores =
        remoteHome.topRatedStores.map((e) => e.toEntity()).toList();

    final vouchers = remoteHome.vouchers.map((e) => e.toEntity()).toList();
    final systemContents = remoteHome.systemContents;

    final favorites = await remote.getHomeFavorites(
      latitude: lat,
      longitude: lon,
    );

    final favoriteStores =
        (favorites['favoriteStores'] as List? ?? []).map((e) {
      final json = Map<String, dynamic>.from(e as Map);
      return FavoriteStore(
        id: json['id'],
        name: json['name'] ?? '',
        address: json['address'],
        logoUrl: json['logoUrl'],
        coverImageUrl: json['coverImageUrl'],
        averageRating: (json['averageRating'] as num?)?.toDouble(),
        totalReviews: json['totalReviews'] as int?,
        distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      );
    }).toList();

    final favoriteServices =
        (favorites['favoriteServices'] as List? ?? []).map((e) {
      final json = Map<String, dynamic>.from(e as Map);
      return FavoriteService(
        id: json['id'],
        name: json['name'] ?? '',
        imageUrl: json['imageUrl'],
        price: (json['price'] as num?)?.toDouble(),
        storeId: json['storeId'] as int?,
        storeName: json['storeName'],
      );
    }).toList();

    return HomeData(
      categories: categories,
      serviceGroups: serviceGroups,
      nearbyStores: nearbyStores,
      topRatedStores: topRatedStores,
      vouchers: vouchers,
      systemContents: systemContents,
      favoriteStores: favoriteStores,
      favoriteServices: favoriteServices,
    );
  }
}
