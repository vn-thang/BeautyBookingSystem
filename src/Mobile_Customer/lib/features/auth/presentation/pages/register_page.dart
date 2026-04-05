import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text_styles.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscure = true;

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            RegisterEvent(
              fullName: fullNameController.text.trim(),
              phone: phoneController.text.trim(),
              email: emailController.text.trim(),
              password: passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    const registerBannerUrl =
        'https://res.cloudinary.com/dbie57o9w/image/upload/v1774166100/4bbf2fac-48e8-4e2d-92d0-dd94f17459fc.png';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppDecorations.pageGradient,
        ),
        child: SafeArea(
          child: BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) =>
                current is AuthError || current is AuthAuthenticated,
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đăng ký thành công")),
                );
                Navigator.pop(context);
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.88),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.borderSoft),
                      boxShadow: AppDecorations.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _backButton(),
                        const SizedBox(height: 10),
                        Center(
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              gradient: AppDecorations.heroGradient,
                              shape: BoxShape.circle,
                              boxShadow: AppDecorations.avatarShadow,
                            ),
                            child: ClipOval(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    registerBannerUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      decoration: const BoxDecoration(
                                        gradient: AppDecorations.heroGradient,
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.person_add_alt_1_rounded,
                                        size: 56,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          AppColors.surface.withOpacity(0.03),
                                          AppColors.placeholderEnd
                                              .withOpacity(0.25),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Center(
                          child: Text(
                            "Tạo tài khoản mới",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.pageTitle,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            "Đăng ký để bắt đầu trải nghiệm dịch vụ của bạn",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMuted,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            children: [
                              _buildField(
                                controller: fullNameController,
                                label: "Họ và tên",
                                icon: Icons.badge_outlined,
                                validator: (value) {
                                  final v = value?.trim() ?? '';
                                  if (v.isEmpty) {
                                    return "Nhập họ tên";
                                  }
                                  if (v.length < 2) {
                                    return "Họ tên quá ngắn";
                                  }
                                  final nameRegex =
                                      RegExp(r"^[A-Za-zÀ-ỹà-ỹ\s'.-]+$");
                                  if (!nameRegex.hasMatch(v)) {
                                    return "Họ tên không hợp lệ";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              _buildField(
                                controller: phoneController,
                                label: "Số điện thoại",
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  final v = value?.trim() ?? '';
                                  if (v.isEmpty) {
                                    return "Nhập số điện thoại";
                                  }

                                  final digitsOnly =
                                      v.replaceAll(RegExp(r'\D'), '');
                                  if (digitsOnly.length != 10) {
                                    return "Số điện thoại phải có 10 chữ số";
                                  }

                                  if (!digitsOnly.startsWith('0')) {
                                    return "Số điện thoại không hợp lệ";
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              _buildField(
                                controller: emailController,
                                label: "Email",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  final v = value?.trim() ?? '';
                                  if (v.isEmpty) {
                                    return "Nhập email";
                                  }

                                  final emailRegex = RegExp(
                                    r'^[\w\.-]+@([\w-]+\.)+[A-Za-z]{2,}$',
                                  );
                                  if (!emailRegex.hasMatch(v)) {
                                    return "Email không hợp lệ";
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              _buildField(
                                controller: passwordController,
                                label: "Mật khẩu",
                                icon: Icons.lock_outline_rounded,
                                obscureText: obscure,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: () {
                                    setState(() => obscure = !obscure);
                                  },
                                ),
                                validator: (value) {
                                  final v = value?.trim() ?? '';
                                  if (v.isEmpty) {
                                    return "Nhập mật khẩu";
                                  }
                                  if (v.length < 6) {
                                    return "Mật khẩu tối thiểu 6 ký tự";
                                  }
                                  if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{6,}$')
                                      .hasMatch(v)) {
                                    return "Mật khẩu phải có chữ và số";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  final isLoading = state is AuthLoading;

                                  return SizedBox(
                                    width: double.infinity,
                                    child: _primaryButton(
                                      text: "Đăng ký",
                                      icon: Icons.person_add_alt_1_rounded,
                                      isLoading: isLoading,
                                      onTap: isLoading ? null : _register,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: _secondaryButton(
                                  text: "Đã có tài khoản? Đăng nhập",
                                  icon: Icons.login_rounded,
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _backButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => Navigator.pop(context),
      child: const Padding(
        padding: EdgeInsets.all(4),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppDecorations.softShadow,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: AppTextStyles.body.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: label,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          errorMaxLines: 2,
          hintStyle: AppTextStyles.bodyMuted,
          prefixIcon: Icon(icon, color: AppColors.primary),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
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
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 1.4,
            ),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            borderSide: BorderSide(
              color: AppColors.danger,
              width: 1.2,
            ),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            borderSide: BorderSide(
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
    required IconData icon,
    required VoidCallback? onTap,
    required bool isLoading,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppColors.primary,
                  ),
                )
              else ...[
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Text(
                  text,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _secondaryButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: AppColors.surface,
            border: Border.all(color: AppColors.borderSoft),
            boxShadow: AppDecorations.softShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                text,
                style: AppTextStyles.bodyMuted.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
