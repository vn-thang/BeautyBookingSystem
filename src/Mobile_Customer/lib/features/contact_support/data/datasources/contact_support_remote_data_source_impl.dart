import 'package:dio/dio.dart';

import '../models/contact_info_model.dart';
import 'contact_support_remote_data_source.dart';

class ContactSupportRemoteDataSourceImpl
    implements ContactSupportRemoteDataSource {
  final Dio dio;

  ContactSupportRemoteDataSourceImpl(this.dio);

  @override
  Future<ContactInfoModel> getContactInfo() async {
    final response = await dio.get('/public/system-configs/contact-info');

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ContactInfoModel.fromJson(data);
    }

    if (data is Map) {
      return ContactInfoModel.fromJson(Map<String, dynamic>.from(data));
    }

    throw Exception('Dữ liệu contact info không hợp lệ');
  }
}
