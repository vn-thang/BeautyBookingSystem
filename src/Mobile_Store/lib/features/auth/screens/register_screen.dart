import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:mobile_store/core/screens/custom_webview_screen.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/buttons/app_buttons.dart';
import '../../../shared/widgets/feedback/app_error_box.dart';
import '../../../shared/widgets/feedback/snackbar_helper.dart';
import '../widgets/auth_components.dart';
import '../services/auth_service.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _serverErrorMessage;
  bool _isAgreed = false;
  late TapGestureRecognizer _termsRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer(); 
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _termsRecognizer.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_serverErrorMessage != null) {
      setState(() {
        _serverErrorMessage = null;
      });
    }
  }

  void _openTermsWebPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomWebViewScreen(
          title: 'Điều khoản và Chính sách',
          url: 'http://localhost:5173/chinh-sach-chung', 
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    _clearError();
    if (!_formKey.currentState!.validate()) return;

    if (!_isAgreed) {
      SnackBarHelper.showError(context, 'Vui lòng đồng ý với Chính sách & điều khoản!');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await AuthService.registerPartner(
        _ownerNameController.text.trim(),
        _phoneController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (result.isSuccess) {
        SnackBarHelper.showSuccess(context, 'Đăng ký thành công! Vui lòng đăng nhập');
        Navigator.pop(context);
      } else {
        setState(() => _serverErrorMessage = result.errorMessage);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _termsRecognizer.onTap = () {
      _openTermsWebPage(context);
    };

    return Scaffold(
      body: AuthGlassBackground(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Đăng ký đối tác',
                style: AppTextStyles.heading1.copyWith(
                  fontSize: 24,
                  color: AppColors.authTextTitle,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Tạo tài khoản cửa hàng của bạn',
                style: AppTextStyles.bodyText.copyWith(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 30),

              AppTextField(
                hint: 'Họ và tên chủ tiệm',
                icon: Icons.person_outline,
                controller: _ownerNameController,
                validator: (val) => FormValidators.requiredField(val, 'Vui lòng nhập họ tên'),
                onChanged: (_) => _clearError(),
              ),
              const SizedBox(height: 14),

              AppTextField(
                hint: 'Số điện thoại',
                icon: Icons.phone_outlined,
                controller: _phoneController,
                validator: FormValidators.phone,
                onChanged: (_) => _clearError(),
              ),
              const SizedBox(height: 14),

              AppTextField(
                hint: 'Email',
                icon: Icons.email_outlined,
                controller: _emailController,
                validator: FormValidators.email,
                onChanged: (_) => _clearError(),
              ),
              const SizedBox(height: 14),

              AppTextField(
                hint: 'Mật khẩu',
                icon: Icons.lock_outline,
                controller: _passwordController,
                isPassword: true,
                validator: (val) => FormValidators.password(val),
                onChanged: (_) => _clearError(),
              ),

              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _isAgreed,
                      activeColor: AppColors.authLink,
                      side: const BorderSide(color: AppColors.authTextBody),
                      onChanged: (bool? value) {
                        setState(() {
                          _isAgreed = value ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: RichText(
                        text: TextSpan(
                          text: 'Tôi đã đọc và đồng ý với ',
                          style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.authTextBody,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: 'Chính sách & điều khoản',
                              style: const TextStyle(
                                color: AppColors.authLink,
                                fontWeight: FontWeight.bold,
                              ),
                              // Gắn recognizer vào TextSpan
                              recognizer: _termsRecognizer, 
                            ),
                            const TextSpan(text: ' dịch vụ của hệ thống.'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (_serverErrorMessage != null) ...[
                const SizedBox(height: 14),
                AppErrorBox(errorMessage: _serverErrorMessage!),
              ],

              const SizedBox(height: 25),
              AppPrimaryButton(
                text: 'ĐĂNG KÝ',
                isLoading: _isLoading,
                onPressed: _handleRegister,
                color: const Color(0xFFFF758C),
              ),

              const SizedBox(height: 20),
              Text(
                'Đã có tài khoản?',
                style: AppTextStyles.bodyText.copyWith(color: AppColors.authTextBody, fontSize: 13),
              ),
              const SizedBox(height: 10),
              AppOutlineButton(
                text: 'ĐĂNG NHẬP NGAY',
                color: AppColors.authLink,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}