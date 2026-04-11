import 'package:image_picker/image_picker.dart';
import '../repositories/auth_repository.dart';

class UploadAvatar {
  final AuthRepository repository;

  UploadAvatar(this.repository);

  Future<void> call(XFile file) {
    return repository.uploadAvatar(file);
  }
}