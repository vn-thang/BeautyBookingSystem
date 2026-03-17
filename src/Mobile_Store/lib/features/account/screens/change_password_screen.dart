import 'package:flutter/material.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_error_box.dart';
import '../../../core/utils/form_validators.dart';
import '../services/account_service.dart';
import '../../../core/theme/app_colors.dart';

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
      _errorMessage = null; // Reset lỗi
    });

    final result = await AccountService.changePassword(
      _oldPassCtrl.text,
      _newPassCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đổi mật khẩu thành công!'), backgroundColor: Colors.green),
      );
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
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: const Text(
          'Đổi mật khẩu',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary, // Đổ màu nền đỏ/hồng
        foregroundColor: AppColors.background, 
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_errorMessage != null) ...[
                AppErrorBox(errorMessage: _errorMessage!),
                const SizedBox(height: 20),
              ],
              
              AppTextField(
                label: 'Mật khẩu hiện tại',
                hint: 'Nhập mật khẩu cũ',
                icon: Icons.lock_outline,
                controller: _oldPassCtrl,
                isPassword: true,
                validator: (val) => FormValidators.requiredField(val, 'Vui lòng nhập mật khẩu cũ'),
              ),
              const SizedBox(height: 16),
              
              AppTextField(
                label: 'Mật khẩu mới',
                hint: 'Ít nhất 6 ký tự',
                icon: Icons.lock_reset,
                controller: _newPassCtrl,
                isPassword: true,
                validator: (val) => FormValidators.password(val, minLength: 6),
              ),
              const SizedBox(height: 16),
              
              AppTextField(
                label: 'Xác nhận mật khẩu mới',
                hint: 'Nhập lại mật khẩu mới',
                icon: Icons.check_circle_outline,
                controller: _confirmPassCtrl,
                isPassword: true,
                validator: (val) => FormValidators.confirmPassword(val, _newPassCtrl.text),
              ),
              const SizedBox(height: 40),
              
              AppGradientButton(
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