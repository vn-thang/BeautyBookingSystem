
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../widgets/auth_components.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/theme/app_colors.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.resetPassword(
      widget.email,
      _otpController.text.trim(),
      _newPasswordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) { 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đổi mật khẩu thành công! Hãy đăng nhập lại."), backgroundColor: Colors.green)
      );
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? "Mã xác nhận không đúng!"), backgroundColor: Colors.red)
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
          'Đặt lại mật khẩu',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18, 
            fontWeight: FontWeight.w600
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20), 
          onPressed: () => Navigator.pop(context)
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
                    "Tạo mật khẩu mới 🔒", 
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      text: "Mã xác nhận đã được gửi đến:\n",
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
                      children: [
                        TextSpan(
                          text: widget.email,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  AppTextField(
                    hint: 'Nhập mã từ email...',
                    icon: Icons.security_outlined,
                    controller: _otpController,
                    validator: (val) => FormValidators.requiredField(val, 'Vui lòng nhập mã OTP'),
                  ),
                  const SizedBox(height: 20),

                  AppTextField(
                    hint: 'Mật khẩu mới',
                    icon: Icons.lock_outline,
                    controller: _newPasswordController,
                    isPassword: true,
                    validator: (val) => FormValidators.password(val),
                  ),
                  const SizedBox(height: 20),

                  AppTextField(
                    hint: 'Xác nhận mật khẩu',
                    icon: Icons.lock_reset_outlined,
                    controller: _confirmPasswordController,
                    isPassword: true,
                    validator: (val) => FormValidators.confirmPassword(val, _newPasswordController.text),
                  ),
                  const SizedBox(height: 40),

                  AuthGradientButton(
                    text: 'Xác nhận & Đổi mật khẩu', 
                    isLoading: _isLoading, 
                    onPressed: _handleResetPassword
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