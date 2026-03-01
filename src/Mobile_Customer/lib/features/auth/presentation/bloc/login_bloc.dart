import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import 'login_event.dart';
import 'login_state.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;
  final FlutterSecureStorage secureStorage;

  LoginBloc({
    required this.loginUseCase,
    required this.secureStorage,
  }) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    try {
      final result = await loginUseCase(
        phone: event.phone,
        password: event.password,
      );

      final token = result.$1;

      // Lưu token
      await secureStorage.write(key: "token", value: token);

      emit(LoginSuccess());
    } catch (e) {
      emit(LoginFailure("Đăng nhập thất bại"));
    }
  }
}