import 'package:dio/dio.dart';
import '../../data/models/service_model.dart';
import '../entities/service.dart';

class GetServiceDetail {
  final Dio dio;

  GetServiceDetail(this.dio);

  Future<Service> call(int id) async {
    final response = await dio.get('/Services/$id');

    final model = ServiceModel.fromJson(response.data);
    return model.toEntity();
  }
}