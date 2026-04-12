import '../entities/contact_info.dart';

abstract class ContactSupportRepository {
  Future<ContactInfo> getContactInfo();
}
