import 'global_category.dart';
import 'service_group.dart';
import 'store.dart';
import 'voucher.dart';
import '../../data/models/system_content_model.dart'; 

class HomeData {
  final List<GlobalCategory> categories;
  final List<ServiceGroup> serviceGroups;
  final List<Store> stores;
  final List<Store> nearbyStores;
  final List<Store> topRatedStores;
  final List<Voucher> vouchers;
  final List<SystemContentModel> systemContents; 

  HomeData({
    required this.categories,
    required this.serviceGroups,
    required this.stores,
    required this.nearbyStores,
    required this.topRatedStores,
    required this.vouchers,
    required this.systemContents,
  });

  HomeData copyWith({
    List<Store>? stores,
    List<Store>? nearbyStores,
    List<Store>? topRatedStores,
  }) {
    return HomeData(
      categories: categories,
      serviceGroups: serviceGroups,
      stores: stores ?? this.stores,
      nearbyStores: nearbyStores ?? this.nearbyStores,
      topRatedStores: topRatedStores ?? this.topRatedStores,
      vouchers: vouchers,
      systemContents: systemContents,
    );
  }
}