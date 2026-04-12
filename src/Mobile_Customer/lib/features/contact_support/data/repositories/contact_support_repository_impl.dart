import '../../domain/entities/contact_info.dart';
import '../../domain/repositories/contact_support_repository.dart';
import '../datasources/contact_support_remote_data_source.dart';

class ContactSupportRepositoryImpl implements ContactSupportRepository {
  final ContactSupportRemoteDataSource remoteDataSource;

  ContactSupportRepositoryImpl(this.remoteDataSource);

  @override
  Future<ContactInfo> getContactInfo() {
    return remoteDataSource.getContactInfo();
  }
}
