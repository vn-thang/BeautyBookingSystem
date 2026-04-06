import '../../../core/network/api_client.dart';
import '../models/contact_info_model.dart';

class SupportApi {
  static Future<ContactInfoModel> getContactInfo() async {
    try {
      final json = await ApiClient.get('/api/public/system-configs/contact-info');
      final data = json['data'] ?? json; 
      
      return ContactInfoModel.fromJson(data);
    } catch (e) {
      return ContactInfoModel(
        hotline: '1900 1234',
        email: 'support@beautybooking.com',
        zalo: '0999999999',
      );
    }
  }
}