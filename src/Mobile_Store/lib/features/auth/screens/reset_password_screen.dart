import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/inputs/app_header.dart'; 
import '../../../shared/widgets/buttons/app_buttons.dart'; 
import '../../../shared/widgets/feedback/snackbar_helper.dart'; 
import '../../../core/utils/form_validators.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

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
      SnackBarHelper.showSuccess(context, "Đổi mật khẩu thành công! Hãy đăng nhập lại.");
      Navigator.pushAndRemoveUntil(
        context, 
        MaterialPageRoute(builder: (context) => const LoginScreen()), 
        (route) => false
      );
    } else {
      SnackBarHelper.showError(context, result.errorMessage ?? "Mã xác nhận không đúng!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Đặt lại mật khẩu'), 
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
                    "Tạo mật khẩu mới 🔒", 
                    style: AppTextStyles.heading1.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  RichText(
                    text: TextSpan(
                      text: "Mã xác nhận đã được gửi đến:\n",
                      style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub),
                      children: [
                        TextSpan(
                          text: widget.email,
                          style: AppTextStyles.bodyText.copyWith(
                            fontWeight: FontWeight.bold, 
                            color: AppColors.textMain
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl * 1.5),

                  AppTextField(
                    hint: 'Nhập mã từ email...',
                    label: 'Mã xác nhận (OTP)',
                    icon: Icons.security_outlined,
                    controller: _otpController,
                    validator: (val) => FormValidators.requiredField(val, 'Vui lòng nhập mã OTP'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  AppTextField(
                    hint: 'Mật khẩu mới',
                    label: 'Mật khẩu mới',
                    icon: Icons.lock_outline,
                    controller: _newPasswordController,
                    isPassword: true,
                    validator: (val) => FormValidators.password(val),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  AppTextField(
                    hint: 'Xác nhận mật khẩu',
                    label: 'Xác nhận mật khẩu',
                    icon: Icons.lock_reset_outlined,
                    controller: _confirmPasswordController,
                    isPassword: true,
                    validator: (val) => FormValidators.confirmPassword(val, _newPasswordController.text),
                  ),
                  const SizedBox(height: AppSpacing.xl * 2),

                  AppPrimaryButton(
                    text: 'XÁC NHẬN & ĐỔI MẬT KHẨU', 
                    isLoading: _isLoading, 
                    onPressed: _handleResetPassword,
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