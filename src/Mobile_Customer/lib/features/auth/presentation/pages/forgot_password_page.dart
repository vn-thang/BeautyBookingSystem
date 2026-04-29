import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text_styles.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _otpFocus = FocusNode();
  final _newPasswordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _otpSent = false;
  bool _otpVerified = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    _emailFocus.dispose();
    _otpFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _sendOtp() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _emailFocus.requestFocus();
      return;
    }

    setState(() => _loading = true);

    context.read<AuthBloc>().add(ForgotPasswordEvent(email));
  }

  void _verifyOtp() {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();

    if (email.isEmpty) {
      _emailFocus.requestFocus();
      return;
    }

    if (otp.isEmpty) {
      _otpFocus.requestFocus();
      return;
    }

    setState(() => _loading = true);

    context.read<AuthBloc>().add(
          VerifyForgotPasswordOtpEvent(
            email: email,
            otp: otp,
          ),
        );
  }

  void _resetPassword() {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty) {
      _newPasswordFocus.requestFocus();
      return;
    }

    if (confirmPassword.isEmpty) {
      _confirmPasswordFocus.requestFocus();
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mật khẩu tối thiểu 6 ký tự"),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mật khẩu xác nhận không khớp"),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    context.read<AuthBloc>().add(
          ResetPasswordEvent(
            _emailController.text.trim(),
            _otpController.text.trim(),
            newPassword,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppDecorations.pageGradient,
        ),
        child: SafeArea(
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                final msg = state.message;

                if (!_otpSent) {
                  setState(() {
                    _otpSent = true;
                    _loading = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(msg),
                      backgroundColor: AppColors.surface,
                    ),
                  );
                  return;
                }

                if (_otpSent && !_otpVerified) {
                  setState(() {
                    _otpVerified = true;
                    _loading = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(msg),
                      backgroundColor: AppColors.surface,
                    ),
                  );
                  return;
                }

                setState(() => _loading = false);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(msg),
                    backgroundColor: AppColors.surface,
                  ),
                );

                Navigator.pop(context);
              }

              if (state is AuthError) {
                setState(() => _loading = false);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.borderSoft),
                  boxShadow: AppDecorations.cardShadow,
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Quên mật khẩu",
                        style: AppTextStyles.pageTitle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Nhập email để nhận OTP và tạo lại mật khẩu mới",
                        style: AppTextStyles.bodyMuted,
                      ),
                      const SizedBox(height: 24),
                      _buildField(
                        controller: _emailController,
                        focusNode: _emailFocus,
                        label: "Email",
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_otpSent,
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) return "Vui lòng nhập email";
                          final emailRegex =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(v))
                            return "Email không hợp lệ";
                          return null;
                        },
                        onSubmitted: _sendOtp,
                      ),
                      const SizedBox(height: 16),
                      if (_otpSent) ...[
                        _buildField(
                          controller: _otpController,
                          focusNode: _otpFocus,
                          label: "OTP",
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return "Vui lòng nhập OTP";
                            return null;
                          },
                          onSubmitted:
                              _otpVerified ? _resetPassword : _verifyOtp,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (_otpVerified) ...[
                        _buildField(
                          controller: _newPasswordController,
                          focusNode: _newPasswordFocus,
                          label: "Mật khẩu mới",
                          obscureText: true,
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return "Vui lòng nhập mật khẩu mới";
                            if (v.length < 6)
                              return "Mật khẩu tối thiểu 6 ký tự";
                            return null;
                          },
                          onSubmitted: () {
                            FocusScope.of(context)
                                .requestFocus(_confirmPasswordFocus);
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocus,
                          label: "Xác nhận mật khẩu mới",
                          obscureText: true,
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return "Vui lòng xác nhận mật khẩu";
                            if (v != _newPasswordController.text.trim()) {
                              return "Mật khẩu xác nhận không khớp";
                            }
                            return null;
                          },
                          onSubmitted: _resetPassword,
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: _primaryButton(
                          text: !_otpSent
                              ? "Gửi OTP"
                              : !_otpVerified
                                  ? "Xác nhận OTP"
                                  : "Lưu mật khẩu mới",
                          onTap: () {
                            if (!(_formKey.currentState?.validate() ?? false)) {
                              return;
                            }

                            if (!_otpSent) {
                              _sendOtp();
                              return;
                            }

                            if (!_otpVerified) {
                              _verifyOtp();
                              return;
                            }

                            _resetPassword();
                          },
                          loading: _loading,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String? Function(String?) validator,
    required VoidCallback onSubmitted,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppDecorations.softShadow,
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        enabled: enabled,
        onFieldSubmitted: (_) => onSubmitted(),
        style: AppTextStyles.body.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: AppTextStyles.bodyMuted,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          errorMaxLines: 2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: AppColors.borderSoft,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.4,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: AppColors.danger,
              width: 1.2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: AppColors.danger,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String text,
    required VoidCallback onTap,
    required bool loading,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (!_otpSent) {
            final email = _emailController.text.trim();
            if (email.isEmpty) {
              _emailFocus.requestFocus();
              return;
            }
            _sendOtp();
            return;
          }

          if (!_otpVerified) {
            final otp = _otpController.text.trim();
            if (otp.isEmpty) {
              _otpFocus.requestFocus();
              return;
            }
            _verifyOtp();
            return;
          }

          _resetPassword();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.placeholderStart,
                AppColors.placeholderEnd,
              ],
            ),
            boxShadow: AppDecorations.cardShadow,
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppColors.primary,
                    ),
                  )
                : Text(
                    text,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
