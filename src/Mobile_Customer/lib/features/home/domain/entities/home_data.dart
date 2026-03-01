import 'global_category.dart';
import 'service_group.dart';
import 'store.dart';
import 'voucher.dart';
class HomeData {
  final List<GlobalCategory> categories;
  final List<ServiceGroup> serviceGroups;
  final List<Store> stores;
  final List<Voucher> vouchers;

  HomeData({
    required this.categories,
    required this.serviceGroups,
    required this.stores,
    required this.vouchers,
  });

  HomeData copyWith({
    List<Store>? stores,
  }) {
    return HomeData(
      categories: categories,
      serviceGroups: serviceGroups,
      stores: stores ?? this.stores,
      vouchers: vouchers,
    );
  }
}