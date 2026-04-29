import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginWithFirebase {
  final AuthRepository repository;

  LoginWithFirebase(this.repository);

  Future<User> call({
    required String idToken,
    String? fcmToken,
    bool linkToExistingAccount = false,
    bool isStoreOwnerApp = false,
  }) {
    return repository.loginWithFirebase(
      idToken: idToken,
      fcmToken: fcmToken,
      linkToExistingAccount: linkToExistingAccount,
      isStoreOwnerApp: isStoreOwnerApp,
    );
  }
}
