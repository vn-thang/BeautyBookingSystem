// lib/features/home/data/models/home_response_model.dart
import 'global_category_model.dart';
import 'service_group_model.dart';
import 'store_model.dart';
import 'voucher_model.dart';
import 'system_content_model.dart';

class HomeResponseModel {
  final String? userName;
  final String? locationName;
  final List<GlobalCategoryModel> categories;
  final List<ServiceGroupModel> serviceGroups;
  final List<StoreModel> nearbyStores;
  final List<StoreModel> topRatedStores;
  final List<VoucherModel> vouchers;
  final List<SystemContentModel> systemContents;

  HomeResponseModel({
    required this.userName,
    required this.locationName,
    required this.categories,
    required this.serviceGroups,
    required this.nearbyStores,
    required this.topRatedStores,
    required this.vouchers,
    required this.systemContents,
  });

  List<SystemContentModel> get banners =>
      systemContents.where((e) => e.isActive == true && e.type == 5).toList();

  static List<T> _safeListParse<T>(
    dynamic value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value == null) return <T>[];
    if (value is List) {
      return value
          .whereType<Map>()
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (value is Map<String, dynamic> && value['data'] is List) {
      return (value['data'] as List)
          .whereType<Map>()
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return <T>[];
  }

  factory HomeResponseModel.fromJson(Map<String, dynamic> json) {
    final effective =
        (json['data'] is Map) ? Map<String, dynamic>.from(json['data']) : json;

    return HomeResponseModel(
      userName: effective['userName']?.toString(),
      locationName: effective['locationName']?.toString(),
      categories: _safeListParse(
        effective['categories'],
        (e) => GlobalCategoryModel.fromJson(e),
      ),
      serviceGroups: _safeListParse(
        effective['serviceGroups'],
        (e) => ServiceGroupModel.fromJson(e),
      ),
      nearbyStores: _safeListParse(
        effective['nearbyStores'],
        (e) => StoreModel.fromJson(e),
      ),
      topRatedStores: _safeListParse(
        effective['topRatedStores'],
        (e) => StoreModel.fromJson(e),
      ),
      vouchers: _safeListParse(
        effective['vouchers'],
        (e) => VoucherModel.fromJson(e),
      ),
      systemContents: _safeListParse(
        effective['systemContents'],
        (e) => SystemContentModel.fromJson(e),
      ),
    );
  }
}
