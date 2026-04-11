import 'package:flutter/material.dart';
import '../../../shared/widgets/inputs/app_text_field.dart'; 
import '../widgets/auth_components.dart'; 
import 'register_screen.dart';
import '../services/auth_service.dart';
import '../../../shared/token_storage.dart';
import '../../store/screens/store_setup_screen.dart';
import 'forgot_password_screen.dart';
import '../../home/screens/main_screen.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/buttons/app_buttons.dart'; 
import '../../../shared/widgets/feedback/app_error_box.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String? _serverErrorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_serverErrorMessage != null) setState(() => _serverErrorMessage = null);
  }

  Future<void> _handleLogin() async {
    _clearError();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final result = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (result.isSuccess) {
        final loginData = result.data!;
        if (loginData.role != 'StoreOwner') {
          setState(() => _serverErrorMessage = "Tài khoản không có quyền truy cập.");
          return; 
        }

        await TokenStorage.saveTokens(loginData.accessToken, loginData.refreshToken);
        if (!mounted) return;
        
        final status = loginData.storeStatus ?? 'Incomplete';
        if (status == 'Incomplete') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StoreSetupScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
        }
      } else {
        setState(() => _serverErrorMessage = result.errorMessage);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthGlassBackground(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Hello Again!', 
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.authTextTitle)),
              const SizedBox(height: 35),
              
              AppTextField(
                hint: 'Email hoặc số điện thoại',
                icon: Icons.person_outline,
                controller: _emailController,
                validator: FormValidators.emailOrPhone, 
                onChanged: (_) => _clearError(),
              ),
              const SizedBox(height: 16),
              
              AppTextField(
                hint: 'Mật khẩu',
                icon: Icons.lock_outline,
                controller: _passwordController,
                isPassword: true,
                validator: (val) => FormValidators.password(val), 
                onChanged: (_) => _clearError(),
              ),
              
              if (_serverErrorMessage != null) ...[
                const SizedBox(height: 10),
                AppErrorBox(errorMessage: _serverErrorMessage!), 
              ],
              
              const SizedBox(height: 25),
              AppPrimaryButton(
                text: 'Đăng nhập', 
                isLoading: _isLoading, 
                onPressed: _handleLogin,
                color: const Color(0xFFFF758C), 
              ),
              
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
                child: const Text('Quên mật khẩu?', 
                  style: TextStyle(color: AppColors.authTextSub, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 30),
              const Text('Chưa có tài khoản?', style: TextStyle(color: AppColors.authTextBody, fontSize: 13)),
              const SizedBox(height: 10),
              AppOutlineButton(
                text: 'Đăng ký ngay',
                color: AppColors.authLink,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}