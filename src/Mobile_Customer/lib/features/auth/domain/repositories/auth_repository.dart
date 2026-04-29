import 'package:image_picker/image_picker.dart';

import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String emailOrPhone, String password);

  Future<User> loginWithFirebase({
    required String idToken,
    String? fcmToken,
    bool linkToExistingAccount = false,
    bool isStoreOwnerApp = false,
  });

  Future<User> register(
    String fullName,
    String phone,
    String email,
    String password,
    String firebaseIdToken,
  );

  Future<User> getProfile();

  Future<void> changePassword(String oldPassword, String newPassword);
  Future<void> forgotPassword(String email);
  Future<void> verifyForgotPasswordOtp(String email, String otp);
  Future<void> resetPassword(String email, String otp, String newPassword);

  Future<void> updateProfile(
    String fullName,
    String? email,
    String? avatarUrl,
  );

  Future<void> uploadAvatar(XFile file);
  Future<void> verifyPhone(String firebaseIdToken);
}
