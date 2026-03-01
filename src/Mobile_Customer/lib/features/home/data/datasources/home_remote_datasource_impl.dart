import 'package:dio/dio.dart';

import '../models/global_category_model.dart';
import '../models/service_group_model.dart';
import '../models/store_model.dart';
import '../models/voucher_model.dart';
import 'home_remote_datasource.dart';

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl(this.dio);

  List<T> _parseList<T>(
    dynamic responseData,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (responseData is List) {
      return responseData.map((e) => fromJson(e)).toList();
    }

    if (responseData is Map<String, dynamic> &&
        responseData['data'] is List) {
      return (responseData['data'] as List)
          .map((e) => fromJson(e))
          .toList();
    }

    throw Exception("Unexpected response format");
  }

  @override
  Future<List<GlobalCategoryModel>> getCategories() async {
    final response = await dio.get('globalcategories');
    return _parseList(
      response.data,
      (e) => GlobalCategoryModel.fromJson(e),
    );
  }

  @override
  Future<List<ServiceGroupModel>> getServiceGroups() async {
    final response = await dio.get('servicegroups');
    return _parseList(
      response.data,
      (e) => ServiceGroupModel.fromJson(e),
    );
  }

  @override
  Future<List<StoreModel>> getStores() async {
    final response = await dio.get('stores');
    return _parseList(
      response.data,
      (e) => StoreModel.fromJson(e),
    );
  }

  @override
  Future<List<VoucherModel>> getVouchers() async {
    final response = await dio.get('vouchers');
    return _parseList(
      response.data,
      (e) => VoucherModel.fromJson(e),
    );
  }
}