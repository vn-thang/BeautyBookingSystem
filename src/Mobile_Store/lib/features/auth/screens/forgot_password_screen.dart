
import 'package:flutter/material.dart';
import '../services/auth_service.dart'; 
import 'reset_password_screen.dart';
import '../widgets/auth_components.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/theme/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final result = await AuthService.forgotPassword(_emailController.text.trim());

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) { 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mã xác nhận đã được gửi vào Email!"), backgroundColor: Colors.green)
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordScreen(email: _emailController.text.trim())));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? "Có lỗi xảy ra!"), backgroundColor: AppColors.primary)
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background, 
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        centerTitle: true,
        title: const Text(
          'Quên mật khẩu',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18, 
            fontWeight: FontWeight.w600
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tìm lại tài khoản 🔑", 
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Đừng lo lắng! Hãy nhập Email của bạn, chúng tôi sẽ gửi mã OTP để đặt lại mật khẩu.", 
                    style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5)
                  ),
                  const SizedBox(height: 32),
                  
                  AppTextField(
                    hint: 'example@gmail.com',
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    validator: FormValidators.email,
                  ),
                  const SizedBox(height: 30),
                  
                  AuthGradientButton(
                    text: 'Gửi mã xác nhận', 
                    isLoading: _isLoading, 
                    onPressed: _handleForgotPassword
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}