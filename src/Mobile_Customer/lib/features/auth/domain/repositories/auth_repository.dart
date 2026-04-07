import '../entities/user.dart';
import 'package:image_picker/image_picker.dart';

abstract class AuthRepository {
  Future<User> login(String emailOrPhone, String password);
  Future<User> register(
    String fullName,
    String phone,
    String email,
    String password,
  );
  Future<User> getProfile();
  Future<void> changePassword(String oldPassword, String newPassword);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String email, String otp, String newPassword);
  Future<void> updateProfile(
    String fullName,
    String? email,
    String? avatarUrl,
  );
  Future<void> uploadAvatar(XFile file);
}