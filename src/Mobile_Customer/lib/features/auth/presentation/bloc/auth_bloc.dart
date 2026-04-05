import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/usecases/login.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/register.dart';
import '../../domain/usecases/change_password.dart';
import '../../domain/usecases/forgot_password.dart';
import '../../domain/usecases/reset_password.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/upload_avatar.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login login;
  final GetProfile getProfile;
  final Register register;
  final ChangePassword changePassword;
  final ForgotPassword forgotPassword;
  final ResetPassword resetPassword;
  final UpdateProfile updateProfile;
  final UploadAvatar uploadAvatar;

  AuthBloc(
    this.login,
    this.getProfile,
    this.register,
    this.changePassword,
    this.forgotPassword,
    this.resetPassword,
    this.updateProfile,
    this.uploadAvatar,
  ) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuth);
    on<RegisterEvent>(_onRegister);
    on<ChangePasswordEvent>(_onChangePassword);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ResetPasswordEvent>(_onResetPassword);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UploadAvatarEvent>(_onUploadAvatar);
  }

  Future<void> _onCheckAuth(
      CheckAuthEvent event, Emitter<AuthState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      emit(AuthUnauthenticated());
      return;
    }

    try {
      final user = await getProfile();

      // k emit lại nếu giống nhau
      if (state is AuthAuthenticated) {
        final current = (state as AuthAuthenticated).user;
        if (current.id == user.id) return;
      }

      emit(AuthAuthenticated(user));
    } catch (e) {
      await prefs.remove("token");
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await login(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await register(
        event.fullName,
        event.phone,
        event.email,
        event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
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
        emit(currentState); // giữ login
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
      if (currentState is AuthAuthenticated) {
        emit(currentState);
      }
    }
  }

  Future<void> _onForgotPassword(
      ForgotPasswordEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await forgotPassword(event.email);
      emit(AuthSuccess("Đã gửi OTP tới email"));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onResetPassword(
      ResetPasswordEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await resetPassword(event.email, event.otp, event.newPassword);
      emit(AuthSuccess("Đổi mật khẩu thành công"));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
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
      await updateProfile(
        event.fullName,
        event.email,
        event.avatarUrl,
      );

      final user = await getProfile();
      emit(AuthAuthenticated(user));
      emit(AuthSuccess("Cập nhật thành công"));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
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
      await uploadAvatar(event.file);

      final user = await getProfile();
      emit(AuthAuthenticated(user));
      emit(AuthSuccess("Cập nhật avatar thành công"));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
      emit(currentState);
    }
  }
}
