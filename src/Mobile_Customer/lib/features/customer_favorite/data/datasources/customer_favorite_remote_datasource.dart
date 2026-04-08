import 'package:dio/dio.dart';

class CustomerFavoriteRemoteDataSource {
  final Dio dio;

  CustomerFavoriteRemoteDataSource(this.dio);

  Future<void> favoriteStore(int storeId) async {
    final res = await dio.post('customer-favorites/store/$storeId');
    if (res.statusCode != 200) {
      throw Exception('Không thể thêm store vào yêu thích');
    }
  }

  Future<void> unfavoriteStore(int storeId) async {
    final res = await dio.delete('customer-favorites/store/$storeId');
    if (res.statusCode != 200) {
      throw Exception('Không thể bỏ yêu thích store');
    }
  }

  Future<void> favoriteService(int serviceId) async {
    final res = await dio.post('customer-favorites/service/$serviceId');
    if (res.statusCode != 200) {
      throw Exception('Không thể thêm service vào yêu thích');
    }
  }

  Future<void> unfavoriteService(int serviceId) async {
    final res = await dio.delete('customer-favorites/service/$serviceId');
    if (res.statusCode != 200) {
      throw Exception('Không thể bỏ yêu thích service');
    }
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
