import 'favorite_service.dart';
import 'favorite_store.dart';
import 'global_category.dart';
import 'service_group.dart';
import 'store.dart';
import 'voucher.dart';
import '../../data/models/system_content_model.dart';

class HomeData {
  final List<GlobalCategory> categories;
  final List<ServiceGroup> serviceGroups;
  final List<Store> nearbyStores;
  final List<Store> topRatedStores;
  final List<Voucher> vouchers;
  final List<SystemContentModel> systemContents;
  final List<FavoriteStore> favoriteStores;
  final List<FavoriteService> favoriteServices;

  HomeData({
    required this.categories,
    required this.serviceGroups,
    required this.nearbyStores,
    required this.topRatedStores,
    required this.vouchers,
    required this.systemContents,
    required this.favoriteStores,
    required this.favoriteServices,
  });

  HomeData copyWith({
    List<Store>? stores,
    List<Store>? nearbyStores,
    List<Store>? topRatedStores,
    List<FavoriteStore>? favoriteStores,
    List<FavoriteService>? favoriteServices,
  }) {
    return HomeData(
      categories: categories,
      serviceGroups: serviceGroups,
      nearbyStores: nearbyStores ?? this.nearbyStores,
      topRatedStores: topRatedStores ?? this.topRatedStores,
      vouchers: vouchers,
      systemContents: systemContents,
      favoriteStores: favoriteStores ?? this.favoriteStores,
      favoriteServices: favoriteServices ?? this.favoriteServices,
    );
  }
}
