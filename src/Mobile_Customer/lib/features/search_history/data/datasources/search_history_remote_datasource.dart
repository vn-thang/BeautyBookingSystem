import 'package:dio/dio.dart';

import '../models/search_history_model.dart';

abstract class SearchHistoryRemoteDataSource {
  Future<List<SearchHistoryModel>> getRecent();
  Future<List<SearchHistoryModel>> record(String keyword);
  Future<List<SearchHistoryModel>> delete(int id);
}

class SearchHistoryRemoteDataSourceImpl
    implements SearchHistoryRemoteDataSource {
  final Dio dio;

  SearchHistoryRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<SearchHistoryModel>> getRecent() async {
    final response = await dio.get('/search-histories/recent');

    final data = response.data as List<dynamic>;
    return data
        .map((e) => SearchHistoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SearchHistoryModel>> record(String keyword) async {
    final response = await dio.post(
      '/search-histories',
      data: {'keyword': keyword},
    );

    final data = response.data as List<dynamic>;
    return data
        .map((e) => SearchHistoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SearchHistoryModel>> delete(int id) async {
    final response = await dio.delete('/search-histories/$id');

    final data = response.data as List<dynamic>;
    return data
        .map((e) => SearchHistoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
