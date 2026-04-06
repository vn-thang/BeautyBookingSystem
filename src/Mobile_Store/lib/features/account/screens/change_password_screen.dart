import 'package:flutter/material.dart';
import 'package:mobile_store/shared/widgets/buttons/app_buttons.dart';
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
import 'package:mobile_store/shared/widgets/inputs/app_header.dart';
import '../services/account_service.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/feedback/app_error_box.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null; 
    });

    final result = await AccountService.changePassword(
      _oldPassCtrl.text,
      _newPassCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      SnackBarHelper.showSuccess(context, 'Đổi mật khẩu thành công!');
      Navigator.pop(context); 
    } else {
      setState(() => _errorMessage = result.errorMessage);
    }
  }

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, 
      appBar: const AppHeader(title: 'Đổi mật khẩu'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_errorMessage != null) ...[
                AppErrorBox(errorMessage: _errorMessage!),
                const SizedBox(height: AppSpacing.xl),
              ],
              
              AppTextField(
                label: 'Mật khẩu hiện tại',
                hint: 'Nhập mật khẩu cũ',
                icon: Icons.lock_outline,
                controller: _oldPassCtrl,
                isPassword: true,
                validator: (val) => FormValidators.requiredField(val, 'Vui lòng nhập mật khẩu cũ'),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              AppTextField(
                label: 'Mật khẩu mới',
                hint: 'Ít nhất 6 ký tự',
                icon: Icons.lock_reset,
                controller: _newPassCtrl,
                isPassword: true,
                validator: (val) => FormValidators.password(val, minLength: 6),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              AppTextField(
                label: 'Xác nhận mật khẩu mới',
                hint: 'Nhập lại mật khẩu mới',
                icon: Icons.check_circle_outline,
                controller: _confirmPassCtrl,
                isPassword: true,
                validator: (val) => FormValidators.confirmPassword(val, _newPassCtrl.text),
              ),
              const SizedBox(height: 40),
              
              AppPrimaryButton(
                text: 'CẬP NHẬT MẬT KHẨU',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}