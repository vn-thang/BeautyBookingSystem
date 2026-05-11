// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/service/fcm_service.dart';
import '../../../notification/domain/usecases/update_fcm_token.dart';
import '../../domain/usecases/change_password.dart';
import '../../domain/usecases/forgot_password.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/login_with_firebase.dart';
import '../../domain/usecases/register.dart';
import '../../domain/usecases/reset_password.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/upload_avatar.dart';
import '../../domain/usecases/verify_forgot_password_otp.dart';
import '../../domain/usecases/verify_phone.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login login;
  final LoginWithFirebase loginWithFirebase;
  final GetProfile getProfile;
  final Register register;
  final ChangePassword changePassword;
  final ForgotPassword forgotPassword;
  final VerifyForgotPasswordOtp verifyForgotPasswordOtp;
  final ResetPassword resetPassword;
  final UpdateProfile updateProfile;
  final UploadAvatar uploadAvatar;
  final VerifyPhone verifyPhone;
  final UpdateFcmToken updateFcmToken;
  final FcmService fcmService;

  Future<void> _profileMutationQueue = Future.value();

  AuthBloc(
    this.login,
    this.loginWithFirebase,
    this.getProfile,
    this.register,
    this.changePassword,
    this.forgotPassword,
    this.verifyForgotPasswordOtp,
    this.resetPassword,
    this.updateProfile,
    this.uploadAvatar,
    this.verifyPhone,
    this.updateFcmToken,
    this.fcmService,
  ) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LoginWithFirebaseEvent>(_onLoginWithFirebase);
    on<VerifyPhoneEvent>(_onVerifyPhone);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuth);
    on<RegisterEvent>(_onRegister);
    on<ChangePasswordEvent>(_onChangePassword);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<VerifyForgotPasswordOtpEvent>(_onVerifyForgotPasswordOtp);
    on<ResetPasswordEvent>(_onResetPassword);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UploadAvatarEvent>(_onUploadAvatar);
  }

  Future<void> _runSerialized(Future<void> Function() action) async {
    final previous = _profileMutationQueue;
    final completer = Completer<void>();
    _profileMutationQueue = completer.future;

    try {
      await previous.catchError((_) {});
      await action();
    } finally {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }

  String _extractMessage(Object e) {
    if (e is DioException) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? data['error'] ?? data['title'];
        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString();
        }
      }

      if (data is String && data.trim().isNotEmpty) {
        return data;
      }

      return e.message ?? 'Đã xảy ra lỗi';
    }

    if (e is Exception) {
      return e.toString().replaceFirst('Exception: ', '');
    }

    return 'Đã xảy ra lỗi';
  }

  Future<void> _syncFcmToken() async {
    try {
      final token = await fcmService.initAndGetToken();
      if (token != null && token.isNotEmpty) {
        await updateFcmToken(token);
      }

      fcmService.onTokenRefresh.listen((newToken) async {
        try {
          if (newToken.isNotEmpty) {
            await updateFcmToken(newToken);
          }
        } catch (_) {
          // bỏ qua để không ảnh hưởng app
        }
      });
    } catch (_) {
      // bỏ qua để không ảnh hưởng đăng nhập
    }
  }

  Future<void> _onCheckAuth(
    CheckAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null || token.isEmpty) {
      emit(AuthUnauthenticated());
      return;
    }

    try {
      final user = await getProfile();
      emit(AuthAuthenticated(user));
      await _syncFcmToken();
    } catch (_) {
      await prefs.remove("token");
      await prefs.remove("refreshToken");
      await prefs.remove("user");
      await prefs.remove("sessionExpired");
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await login(event.email, event.password);
      emit(AuthAuthenticated(user));
      await _syncFcmToken();
    } catch (e) {
      emit(AuthError(_extractMessage(e)));
    }
  }

  Future<void> _onLoginWithFirebase(
    LoginWithFirebaseEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await loginWithFirebase(
        idToken: event.idToken,
        fcmToken: event.fcmToken,
        linkToExistingAccount: event.linkToExistingAccount,
        isStoreOwnerApp: event.isStoreOwnerApp,
      );
      emit(AuthAuthenticated(user));
      await _syncFcmToken();
    } catch (e) {
      emit(AuthError(_extractMessage(e)));
    }
  }

  Future<void> _onVerifyPhone(
    VerifyPhoneEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await verifyPhone(event.firebaseIdToken);
      final user = await getProfile();

      emit(AuthSuccess("Xác minh số điện thoại thành công"));
      emit(AuthAuthenticated(user));
      await _syncFcmToken();
    } catch (e) {
      emit(AuthError(_extractMessage(e)));
    }
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await register(
        event.fullName,
        event.phone,
        event.email,
        event.password,
        event.firebaseIdToken,
      );
      emit(AuthAuthenticated(user));
      await _syncFcmToken();
    } catch (e) {
      emit(AuthError(_extractMessage(e)));
    }
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;

    try {
      await changePassword(event.oldPassword, event.newPassword);

      emit(AuthSuccess("Đổi mật khẩu thành công"));

      if (currentState is AuthAuthenticated) {
        emit(currentState);
      }
    } catch (e) {
      emit(AuthError(_extractMessage(e)));
      if (currentState is AuthAuthenticated) {
        emit(currentState);
      }
    }
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await forgotPassword(event.email);
      emit(AuthSuccess("Đã gửi OTP tới email"));
    } catch (e) {
      emit(AuthError(_extractMessage(e)));
    }
  }

  Future<void> _onVerifyForgotPasswordOtp(
    VerifyForgotPasswordOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await verifyForgotPasswordOtp(event.email, event.otp);
      emit(AuthSuccess("Xác nhận OTP thành công"));
    } catch (e) {
      emit(AuthError(_extractMessage(e)));
    }
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await resetPassword(event.email, event.otp, event.newPassword);
      emit(AuthSuccess("Đổi mật khẩu thành công"));
    } catch (e) {
      emit(AuthError(_extractMessage(e)));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("refreshToken");
    await prefs.remove("user");
    await prefs.remove("sessionExpired");
    emit(AuthUnauthenticated());
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;

    if (currentState is! AuthAuthenticated) return;

    try {
      await _runSerialized(() async {
        await updateProfile(
          event.fullName,
          event.email,
          event.avatarUrl,
        );

        final freshUser = await getProfile();

        emit(AuthSuccess("Cập nhật thông tin thành công"));
        emit(AuthAuthenticated(freshUser));
      });
    } catch (e) {
      emit(AuthError(_extractMessage(e)));
      emit(currentState);
    }
  }

  Future<void> _onUploadAvatar(
    UploadAvatarEvent event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;

    if (currentState is! AuthAuthenticated) return;

    try {
      await _runSerialized(() async {
        await uploadAvatar(event.file);

        final freshUser = await getProfile();

        emit(AuthSuccess("Cập nhật avatar thành công"));
        emit(AuthAuthenticated(freshUser));
      });
    } catch (e) {
      emit(AuthError(_extractMessage(e)));
      emit(currentState);
    }
  }
}
