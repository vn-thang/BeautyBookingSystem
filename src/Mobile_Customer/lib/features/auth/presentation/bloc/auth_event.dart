import 'package:image_picker/image_picker.dart';

abstract class AuthEvent {}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({
    required this.email,
    required this.password,
  });
}

class RegisterEvent extends AuthEvent {
  final String fullName;
  final String phone;
  final String email;
  final String password;
  final String firebaseIdToken;

  RegisterEvent({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.password,
    required this.firebaseIdToken,
  });
}

class VerifyPhoneEvent extends AuthEvent {
  final String firebaseIdToken;
  VerifyPhoneEvent(this.firebaseIdToken);
}

class ChangePasswordEvent extends AuthEvent {
  final String oldPassword;
  final String newPassword;
  ChangePasswordEvent(this.oldPassword, this.newPassword);
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;
  ForgotPasswordEvent(this.email);
}

class VerifyForgotPasswordOtpEvent extends AuthEvent {
  final String email;
  final String otp;

  VerifyForgotPasswordOtpEvent({
    required this.email,
    required this.otp,
  });
}

class ResetPasswordEvent extends AuthEvent {
  final String email;
  final String otp;
  final String newPassword;
  ResetPasswordEvent(this.email, this.otp, this.newPassword);
}

class UpdateProfileEvent extends AuthEvent {
  final String fullName;
  final String? email;
  final String? avatarUrl;
  UpdateProfileEvent(this.fullName, this.email, this.avatarUrl);
}

class UploadAvatarEvent extends AuthEvent {
  final XFile file;
  UploadAvatarEvent(this.file);
}

class LoginWithFirebaseEvent extends AuthEvent {
  final String idToken;
  final String? fcmToken;
  final bool linkToExistingAccount;
  final bool isStoreOwnerApp;

  LoginWithFirebaseEvent({
    required this.idToken,
    this.fcmToken,
    this.linkToExistingAccount = false,
    this.isStoreOwnerApp = false,
  });
}

class LogoutEvent extends AuthEvent {}

class CheckAuthEvent extends AuthEvent {}

class RestoreSessionEvent extends AuthEvent {}
