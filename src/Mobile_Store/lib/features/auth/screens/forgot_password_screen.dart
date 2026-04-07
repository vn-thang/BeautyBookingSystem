import 'package:flutter/material.dart';
import '../services/auth_service.dart'; 
import 'reset_password_screen.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/inputs/app_header.dart'; 
import '../../../shared/widgets/buttons/app_buttons.dart';
import '../../../shared/widgets/feedback/snackbar_helper.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

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
      SnackBarHelper.showSuccess(context, "Mã xác nhận đã được gửi vào Email!");
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => ResetPasswordScreen(email: _emailController.text.trim()))
      );
    } else {
      SnackBarHelper.showError(context, result.errorMessage ?? "Có lỗi xảy ra!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, 
      appBar: const AppHeader(title: 'Quên mật khẩu'), 
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingMedium, 
            vertical: AppDimens.paddingLarge
          ),
          child: Container(
            padding: const EdgeInsets.all(AppDimens.paddingLarge),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textMain.withValues(alpha: 0.03),
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
                  Text(
                    "Tìm lại tài khoản 🔑", 
                    style: AppTextStyles.heading1.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    "Đừng lo lắng! Hãy nhập Email của bạn, chúng tôi sẽ gửi mã OTP để đặt lại mật khẩu.", 
                    style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub),
                  ),
                  const SizedBox(height: AppSpacing.xl * 1.5),
                  
                  AppTextField(
                    hint: 'example@gmail.com',
                    label: 'Email tài khoản',
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    validator: FormValidators.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.xl * 1.5),
                  
                  AppPrimaryButton(
                    text: 'GỬI MÃ XÁC NHẬN', 
                    isLoading: _isLoading, 
                    onPressed: _handleForgotPassword,
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