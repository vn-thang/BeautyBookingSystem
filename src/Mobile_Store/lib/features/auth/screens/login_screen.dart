
import 'package:flutter/material.dart';
import '../../../shared/widgets/app_text_field.dart'; 
import '../widgets/auth_components.dart'; 
import 'register_screen.dart';
import '../services/auth_service.dart';
import '../../../shared/token_storage.dart';
import '../../store/screens/store_setup_screen.dart';
import 'forgot_password_screen.dart';
import '../../home/screens/main_screen.dart';
import '../../../core/utils/form_validators.dart';

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
          setState(() => _serverErrorMessage = "Tài khoản không có quyền truy cập ứng dụng Chủ cửa hàng.");
          return; 
        }

        await TokenStorage.saveTokens(loginData.accessToken, loginData.refreshToken);

        if (!mounted) return;
        final status = loginData.storeStatus ?? 'Incomplete';
        switch (status) {
          case 'Incomplete':
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StoreSetupScreen()));
            break;
          case 'Pending':
          case 'Approved':
          case 'Locked':
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
            break;
          default:
            setState(() => _serverErrorMessage = "Trạng thái cửa hàng không hợp lệ: $status");
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
              const Text('Hello Again!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              const SizedBox(height: 8),
              const Text("Welcome back you've\nbeen missed!", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 13)),
              const SizedBox(height: 35),
              
             AppTextField(
            hint: 'Email hoặc số điện thoại',
            icon: Icons.person_outline,
            controller: _emailController,
            // Gọi hàm dùng chung (không cần truyền param, Flutter tự truyền value)
            validator: FormValidators.emailOrPhone, 
            onChanged: (_) => _clearError(),
            ),
              const SizedBox(height: 16),
              
             AppTextField(
  hint: 'Mật khẩu',
  icon: Icons.lock_outline,
  controller: _passwordController,
  isPassword: true,
  // Gọi hàm dùng chung
  validator: (val) => FormValidators.password(val), 
  onChanged: (_) => _clearError(),
),
              
              if (_serverErrorMessage != null) AuthErrorBox(errorMessage: _serverErrorMessage!),
              
              const SizedBox(height: 25),
              AuthGradientButton(text: 'Đăng nhập', isLoading: _isLoading, onPressed: _handleLogin),
              
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
                child: const Text('Quên mật khẩu?', style: TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 30),
              const Text('Chưa có tài khoản?', style: TextStyle(color: Color(0xFF334155), fontSize: 13)),
              const SizedBox(height: 10),
              AuthOutlineButton(
                text: 'Đăng ký ngay',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}