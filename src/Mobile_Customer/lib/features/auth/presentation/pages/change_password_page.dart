import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final formKey = GlobalKey<FormState>();

  final oldPass = TextEditingController();
  final newPass = TextEditingController();
  final confirmPass = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    oldPass.dispose();
    newPass.dispose();
    confirmPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.surface,
            ),
          );
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppDecorations.pageGradient,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "Đổi mật khẩu",
                        style: AppTextStyles.sectionTitle,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.borderSoft),
                      boxShadow: AppDecorations.cardShadow,
                    ),
                    child: Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          _passwordField(
                            controller: oldPass,
                            labelText: "Mật khẩu cũ",
                            obscureText: _obscureOld,
                            onToggleObscure: () {
                              setState(() => _obscureOld = !_obscureOld);
                            },
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) {
                                return "Vui lòng nhập mật khẩu cũ";
                              }
                              if (v.length < 6) {
                                return "Mật khẩu tối thiểu 6 ký tự";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _passwordField(
                            controller: newPass,
                            labelText: "Mật khẩu mới",
                            obscureText: _obscureNew,
                            onToggleObscure: () {
                              setState(() => _obscureNew = !_obscureNew);
                            },
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) {
                                return "Vui lòng nhập mật khẩu mới";
                              }
                              if (v.length < 6) {
                                return "Mật khẩu tối thiểu 6 ký tự";
                              }
                              if (v == oldPass.text.trim()) {
                                return "Mật khẩu mới phải khác mật khẩu cũ";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _passwordField(
                            controller: confirmPass,
                            labelText: "Xác nhận mật khẩu mới",
                            obscureText: _obscureConfirm,
                            onToggleObscure: () {
                              setState(
                                  () => _obscureConfirm = !_obscureConfirm);
                            },
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) {
                                return "Vui lòng xác nhận mật khẩu mới";
                              }
                              if (v != newPass.text.trim()) {
                                return "Mật khẩu xác nhận không khớp";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (!(formKey.currentState?.validate() ??
                                    false)) {
                                  return;
                                }

                                context.read<AuthBloc>().add(
                                      ChangePasswordEvent(
                                        oldPass.text.trim(),
                                        newPass.text.trim(),
                                      ),
                                    );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text("Xác nhận"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
    required VoidCallback onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: AppTextStyles.bodyMuted,
        filled: true,
        fillColor: AppColors.surfaceSoft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        errorMaxLines: 2,
        suffixIcon: IconButton(
          onPressed: onToggleObscure,
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.textSecondary,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.borderSoft),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.primary, width: 1.2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.danger, width: 1.2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.danger, width: 1.2),
        ),
      ),
    );
  }
}
