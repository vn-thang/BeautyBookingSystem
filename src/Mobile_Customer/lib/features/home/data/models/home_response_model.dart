// lib/features/home/data/models/home_response_model.dart
import 'global_category_model.dart';
import 'service_group_model.dart';
import 'store_model.dart';
import 'voucher_model.dart';
import 'system_content_model.dart';

class HomeResponseModel {
  final List<GlobalCategoryModel> categories;
  final List<ServiceGroupModel> serviceGroups;
  final List<StoreModel> stores;
  final List<StoreModel> nearbyStores;
  final List<StoreModel> topRatedStores;
  final List<VoucherModel> vouchers;
  final List<SystemContentModel> systemContents;

  HomeResponseModel({
    required this.categories,
    required this.serviceGroups,
    required this.stores,
    required this.nearbyStores,
    required this.topRatedStores,
    required this.vouchers,
    required this.systemContents,
  });

  static List<T> _safeListParse<T>(
    dynamic value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (value == null) return <T>[];
    if (value is List) {
      return value
          .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    if (value is Map<String, dynamic> && value['data'] is List) {
      return (value['data'] as List)
          .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }
    return <T>[];
  }

  factory HomeResponseModel.fromJson(Map<String, dynamic> json) {
    // nếu server trả wrapper { data: { categories: [...], ... } }
    final effective = (json['data'] is Map) ? Map<String, dynamic>.from(json['data']) : json;

    final cats = _safeListParse<GlobalCategoryModel>(
      effective['categories'],
      (e) => GlobalCategoryModel.fromJson(e),
    );

    final groups = _safeListParse<ServiceGroupModel>(
      effective['serviceGroups'],
      (e) => ServiceGroupModel.fromJson(e),
    );

    final stores = _safeListParse<StoreModel>(
      effective['stores'],
      (e) => StoreModel.fromJson(e),
    );

    final nearby = _safeListParse<StoreModel>(
    effective['nearbyStores'],
    (e) => StoreModel.fromJson(e),
    );
    final topRated = _safeListParse<StoreModel>(
      effective['topRatedStores'],
      (e) => StoreModel.fromJson(e),
    );

    final vouchers = _safeListParse<VoucherModel>(
      effective['vouchers'],
      (e) => VoucherModel.fromJson(e),
    );

    final systemContents = _safeListParse<SystemContentModel>(
      effective['systemContents'],
      (e) => SystemContentModel.fromJson(e),
    );

    return HomeResponseModel(
      categories: cats,
      serviceGroups: groups,
      stores: stores,
      nearbyStores: nearby,
      topRatedStores: topRated,
      vouchers: vouchers,
      systemContents: systemContents,
    );
  }
}