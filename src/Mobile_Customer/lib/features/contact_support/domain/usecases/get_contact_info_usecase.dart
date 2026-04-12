import '../entities/contact_info.dart';
import '../repositories/contact_support_repository.dart';

class GetContactInfoUseCase {
  final ContactSupportRepository repository;

  GetContactInfoUseCase(this.repository);

  Future<ContactInfo> call() {
    return repository.getContactInfo();
  }
}
