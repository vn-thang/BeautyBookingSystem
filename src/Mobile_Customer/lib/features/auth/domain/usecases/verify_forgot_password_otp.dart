import '../repositories/auth_repository.dart';

class VerifyForgotPasswordOtp {
  final AuthRepository repository;

  VerifyForgotPasswordOtp(this.repository);

  Future<void> call(String email, String otp) {
    return repository.verifyForgotPasswordOtp(email, otp);
  }
}
