import '../models/contact_info_model.dart';

abstract class ContactSupportRemoteDataSource {
  Future<ContactInfoModel> getContactInfo();
}
