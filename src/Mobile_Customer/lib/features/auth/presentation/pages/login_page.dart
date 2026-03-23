import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  final String? redirectPath;

  const LoginPage({super.key, this.redirectPath});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailOrPhoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailOrPhoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _checkSessionExpired();
  }

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    _emailOrPhoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final expired = prefs.getString("sessionExpired");

    if (expired == "1") {
      await prefs.remove("sessionExpired");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const pinkMain = Color(0xFFFF6FAF);
    const pinkDeep = Color(0xFFE85E9C);
    const pinkSoft = Color(0xFFFFEEF5);
    const textDark = Color(0xFF4A4A4A);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF7FB),
              Color(0xFFFFEEF5),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                if (widget.redirectPath != null) {
                  context.go(widget.redirectPath!);
                } else {
                  context.go('/');
                }
              }

              if (state is AuthSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }

              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _backButton(),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.80),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: pinkMain.withOpacity(0.10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          Container(
                            width: 190,
                            height: 190,
                            decoration: BoxDecoration(
                              color: pinkSoft,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: pinkMain.withOpacity(0.12),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.network(
                                'https://res.cloudinary.com/dbie57o9w/image/upload/v1774090680/ae61e167-0891-4498-8167-c2191898f6da.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.favorite,
                                  size: 72,
                                  color: pinkMain,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Chào mừng trở lại",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Đăng nhập để tiếp tục trải nghiệm dịch vụ của bạn",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 28),
                          _buildField(
                            controller: _emailOrPhoneController,
                            focusNode: _emailOrPhoneFocusNode,
                            label: "Email hoặc SĐT",
                            icon: Icons.person_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) {
                                return "Vui lòng nhập email hoặc số điện thoại";
                              }
                              return null;
                            },
                            onSubmitted: () {
                              FocusScope.of(context)
                                  .requestFocus(_passwordFocusNode);
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            label: "Mật khẩu",
                            icon: Icons.lock_outline_rounded,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) {
                                return "Mật khẩu không được để trống";
                              }
                              if (v.length < 6) {
                                return "Mật khẩu tối thiểu 6 ký tự";
                              }
                              return null;
                            },
                            onSubmitted: _login,
                          ),
                          const SizedBox(height: 24),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              if (state is AuthLoading) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: CircularProgressIndicator(),
                                );
                              }

                              return SizedBox(
                                width: double.infinity,
                                child: _primaryButton(
                                  text: "Đăng nhập",
                                  icon: Icons.login_rounded,
                                  onTap: _login,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: _secondaryButton(
                              text: "Chưa có tài khoản? Đăng ký",
                              icon: Icons.person_add_alt_1_rounded,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<AuthBloc>(),
                                      child: RegisterPage(),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: _secondaryButton(
                              text: "Quên mật khẩu?",
                              icon: Icons.help_outline_rounded,
                              onTap: () {
                                _showForgotDialog(context);
                              },
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

  Widget _backButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => context.go('/'),
      child: const Padding(
        padding: EdgeInsets.all(4),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: Color(0xFFFF6FAF),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    required TextInputAction textInputAction,
    required VoidCallback onSubmitted,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        validator: validator,
        onFieldSubmitted: (_) => onSubmitted(),
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF333333),
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFFFF6FAF)),
          filled: true,
          fillColor: Colors.white,
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
              color: Colors.pink.shade100,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xFFFF6FAF),
              width: 1.4,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xFFE85E9C),
              width: 1.2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xFFE85E9C),
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  void _login() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      _focusFirstInvalidField();
      return;
    }

    final emailOrPhone = _emailOrPhoneController.text.trim();
    final password = _passwordController.text.trim();

    context.read<AuthBloc>().add(
          LoginEvent(
            email: emailOrPhone,
            password: password,
          ),
        );
  }

  void _focusFirstInvalidField() {
    final emailOrPhone = _emailOrPhoneController.text.trim();
    final password = _passwordController.text.trim();

    if (emailOrPhone.isEmpty) {
      _emailOrPhoneFocusNode.requestFocus();
      return;
    }

    if (password.isEmpty || password.length < 6) {
      _passwordFocusNode.requestFocus();
      return;
    }
  }

  void _showForgotDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final email = TextEditingController();
    final otp = TextEditingController();
    final newPass = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        backgroundColor: const Color(0xFFFFFBFD),
        title: const Text(
          "Quên mật khẩu",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A4A4A),
          ),
        ),
        content: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: email,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return "Vui lòng nhập email";
                    final emailRegex =
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(v)) return "Email không hợp lệ";
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: otp,
                  decoration: const InputDecoration(labelText: "OTP"),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return "Vui lòng nhập OTP";
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newPass,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Mật khẩu mới"),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return "Vui lòng nhập mật khẩu mới";
                    if (v.length < 6) return "Mật khẩu tối thiểu 6 ký tự";
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        actions: [
          _dialogButton(
            text: "Gửi OTP",
            primary: false,
            onTap: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              context
                  .read<AuthBloc>()
                  .add(ForgotPasswordEvent(email.text.trim()));
            },
          ),
          const SizedBox(width: 10),
          _dialogButton(
            text: "Xác nhận",
            primary: true,
            onTap: () {
              if (!(formKey.currentState?.validate() ?? false)) return;

              context.read<AuthBloc>().add(
                    ResetPasswordEvent(
                      email.text.trim(),
                      otp.text.trim(),
                      newPass.text.trim(),
                    ),
                  );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _primaryButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
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
                Color(0xFFFF8FC1),
                Color(0xFFFF6FAF),
                Color(0xFFE85E9C),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6FAF).withOpacity(0.30),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.85),
                blurRadius: 8,
                offset: const Offset(-2, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
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
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Color(0xFFFFF4F8),
              ],
            ),
            border: Border.all(color: const Color(0xFFFFD1E3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 8,
                offset: const Offset(-2, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: const Color(0xFFE85E9C)),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE85E9C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogButton({
    required String text,
    required VoidCallback onTap,
    required bool primary,
  }) {
    final gradient = primary
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF8FC1),
              Color(0xFFFF6FAF),
              Color(0xFFE85E9C),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFFFF4F8),
            ],
          );

    final textColor = primary ? Colors.white : const Color(0xFFE85E9C);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: gradient,
            border: Border.all(
              color: primary ? Colors.transparent : const Color(0xFFFFD1E3),
            ),
            boxShadow: [
              BoxShadow(
                color: primary
                    ? const Color(0xFFFF6FAF).withOpacity(0.26)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
