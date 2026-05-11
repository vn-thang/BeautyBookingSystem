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

  @override
  Future<HomeResponseModel> getHome(double lat, double lon) async {
    final response = await dio.get(
      'home',
      queryParameters: {
        'lat': lat,
        'lon': lon,
      },
    );

    return HomeResponseModel.fromJson(response.data);
  }

  @override
  Future<List<GlobalCategoryModel>> getCategories() async {
    final response = await dio.get('globalcategories/active');

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

  @override
  Future<List<ServiceGroupModel>> getServiceGroups() async {
    final response = await dio.get('servicegroups');

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

  @override
  Future<List<StoreModel>> getStores() async {
    final response = await dio.get('customer/stores');

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

  @override
  Future<List<VoucherModel>> getVouchers() async {
    final response = await dio.get('voucher/active');

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
  Future<List<VoucherModel>> getVouchersService(
    int serviceId, {
    int? storeId,
  }) async {
    final response = await dio.get(
      'voucher/service/$serviceId/active',
      queryParameters: {
        if (storeId != null) 'storeId': storeId,
      },
    );

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

  Future<List<VoucherModel>> getHomeServiceVouchers({int? storeId}) async {
    final response = await dio.get(
      'voucher/service/home',
      queryParameters: {
        if (storeId != null) 'storeId': storeId,
      },
    );

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

    throw Exception("Unexpected home vouchers response");
  }

  @override
  Future<List<StoreModel>> getStoresByCategory(int categoryId) async {
    final response = await dio.get(
      'customer/stores/by-category',
      queryParameters: {'CategoryId': categoryId},
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

  @override
  Future<List<StoreModel>> getStoresByGroup(int groupId) async {
    final response = await dio.get(
      'customer/stores/by-group',
      queryParameters: {'GroupId': groupId},
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

  @override
  Future<StoreModel> getStoreById(int id) async {
    final response = await dio.get('customer/stores/$id');

    if (response.data is Map<String, dynamic>) {
      return StoreModel.fromJson(Map<String, dynamic>.from(response.data));
    }

    throw Exception("Unexpected response for store detail");
  }

  Future<List<StoreModel>> getNearbyStores(double lat, double lng) async {
    final response = await dio.get(
      'stores/nearby',
      queryParameters: {
        'lat': lat,
        'lng': lng,
      },
    );

    return (response.data as List)
        .map((e) => StoreModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Map<String, dynamic>> getHomeFavorites({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await dio.get(
        'customer-favorites/home',
        queryParameters: {
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        },
      );

      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return {};
      }
      rethrow;
    }
  }
}
