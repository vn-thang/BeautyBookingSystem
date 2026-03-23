import 'package:dio/dio.dart';
import '../models/search_store_model.dart';

class SearchRemoteDataSource {
  final Dio dio;

  SearchRemoteDataSource(this.dio);

  Map<String, dynamic> _cleanQuery({
    String? keyword,
    String? location,
    double? userLat,
    double? userLng,
    String? sortBy,
    int? minRating,
    double? minPrice,
    double? maxPrice,
  }) {
    final query = <String, dynamic>{};

    if (keyword != null && keyword.trim().isNotEmpty) {
      query['keyword'] = keyword.trim();
    }
    if (location != null && location.trim().isNotEmpty) {
      query['location'] = location.trim();
    }
    if (userLat != null) query['userLat'] = userLat;
    if (userLng != null) query['userLng'] = userLng;
    if (sortBy != null && sortBy.trim().isNotEmpty) {
      query['sortBy'] = sortBy;
    }
    if (minRating != null) query['minRating'] = minRating;
    if (minPrice != null) query['minPrice'] = minPrice;
    if (maxPrice != null) query['maxPrice'] = maxPrice;

    return query;
  }

  Future<List<SearchStoreModel>> search({
    String? keyword,
    String? location,
    double? userLat,
    double? userLng,
    String sortBy = "nearest",
    int? minRating,
    double? minPrice,
    double? maxPrice,
  }) async {
    final res = await dio.get(
      '/search',
      queryParameters: _cleanQuery(
        keyword: keyword,
        location: location,
        userLat: userLat,
        userLng: userLng,
        sortBy: sortBy,
        minRating: minRating,
        minPrice: minPrice,
        maxPrice: maxPrice,
      ),
    );

    final data = res.data;

    if (data is List) {
      return data.map((e) => SearchStoreModel.fromJson(e)).toList();
    }

    return [];
  }
}
