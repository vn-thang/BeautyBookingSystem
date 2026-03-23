// lib/features/home/data/datasources/home_remote_datasource_impl.dart
import 'package:dio/dio.dart';

import '../models/global_category_model.dart';
import '../models/service_group_model.dart';
import '../models/store_model.dart';
import '../models/voucher_model.dart';
import 'home_remote_datasource.dart';
import '../models/store_list_response.dart';
import '../models/home_response_model.dart';

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl(this.dio);

  /// HOME API (MAIN API)
  @override
  Future<HomeResponseModel> getHome(double lat, double lon) async {
    final response = await dio.get(
      "home",
      queryParameters: {
        "lat": lat,
        "lon": lon,
      },
    );
    final model = HomeResponseModel.fromJson(response.data);
    return model;
  }

  /// GLOBAL CATEGORIES
  @override
  Future<List<GlobalCategoryModel>> getCategories() async {
    final response = await dio.get("globalcategories");

    if (response.data is List) {
      return (response.data as List)
          .map(
              (e) => GlobalCategoryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (response.data is Map && response.data["data"] is List) {
      return (response.data["data"] as List)
          .map(
              (e) => GlobalCategoryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    throw Exception("Unexpected categories response");
  }

  /// SERVICE GROUPS
  @override
  Future<List<ServiceGroupModel>> getServiceGroups() async {
    final response = await dio.get("servicegroups");

    if (response.data is List) {
      return (response.data as List)
          .map((e) => ServiceGroupModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (response.data is Map && response.data["data"] is List) {
      return (response.data["data"] as List)
          .map((e) => ServiceGroupModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    throw Exception("Unexpected service groups response");
  }

  /// STORES
  @override
  Future<List<StoreModel>> getStores() async {
    final response = await dio.get("stores");

    if (response.data is List) {
      return (response.data as List)
          .map((e) => StoreModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (response.data is Map && response.data["data"] is List) {
      return (response.data["data"] as List)
          .map((e) => StoreModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    throw Exception("Unexpected stores response");
  }

  /// VOUCHERS
  @override
  Future<List<VoucherModel>> getVouchers() async {
    final response = await dio.get("voucher/active");

    if (response.data is List) {
      return (response.data as List)
          .map((e) => VoucherModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (response.data is Map && response.data["data"] is List) {
      return (response.data["data"] as List)
          .map((e) => VoucherModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    throw Exception("Unexpected vouchers response");
  }

  @override
  Future<List<VoucherModel>> getVouchersService(int serviceId,
      {int? storeId}) async {
    final response = await dio.get('/api/voucher/service/home');

    if (response.data is List) {
      return (response.data as List)
          .map((e) => VoucherModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (response.data is Map && response.data["data"] is List) {
      return (response.data["data"] as List)
          .map((e) => VoucherModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    throw Exception("Unexpected vouchers by service response");
  }

  /// STORES BY CATEGORY
  @override
  Future<List<StoreModel>> getStoresByCategory(int categoryId) async {
    final response = await dio.get(
      "stores/by-category",
      queryParameters: {"CategoryId": categoryId},
    );

    if (response.data is Map<String, dynamic>) {
      final parsed =
          StoreListResponse.fromJson(Map<String, dynamic>.from(response.data));
      return parsed.items;
    }

    if (response.data is List) {
      return (response.data as List)
          .map((e) => StoreModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    throw Exception("Unexpected response for stores by category");
  }

  /// STORES BY GROUP
  @override
  Future<List<StoreModel>> getStoresByGroup(int groupId) async {
    final response = await dio.get(
      "stores/by-group",
      queryParameters: {"GroupId": groupId},
    );

    if (response.data is Map<String, dynamic>) {
      final parsed =
          StoreListResponse.fromJson(Map<String, dynamic>.from(response.data));
      return parsed.items;
    }

    if (response.data is List) {
      return (response.data as List)
          .map((e) => StoreModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    throw Exception("Unexpected response for stores by group");
  }

  /// STORE DETAIL
  @override
  Future<StoreModel> getStoreById(int id) async {
    final response = await dio.get("stores/$id");

    if (response.data is Map<String, dynamic>) {
      return StoreModel.fromJson(Map<String, dynamic>.from(response.data));
    }

    throw Exception("Unexpected response for store detail");
  }

  /// NEARBY STORES
  Future<List<StoreModel>> getNearbyStores(double lat, double lng) async {
    final response = await dio.get(
      "stores/nearby",
      queryParameters: {
        "lat": lat,
        "lng": lng,
      },
    );

    return (response.data as List)
        .map((e) => StoreModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
