import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text_styles.dart';

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

  bool _phoneDialogShown = false;
  String? _pendingFirebaseIdToken;
  bool _isShowingLinkDialog = false;

  String _normalizePhoneNumber(String phone) {
    phone = phone.trim().replaceAll(RegExp(r'[^\d+]'), '');

    if (phone.startsWith('0')) {
      return '+84${phone.substring(1)}';
    }

    if (phone.startsWith('84') && !phone.startsWith('+84')) {
      return '+$phone';
    }

    return phone;
  }

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

  bool _needsPhoneVerification(dynamic user) {
    final phone = (user.phone as String?)?.trim() ?? '';
    final verified = user.isPhoneVerified == true;
    return phone.isEmpty || !verified;
  }

  void _showVerifyPhoneDialog() {
    final formKey = GlobalKey<FormState>();
    final phoneController = TextEditingController();
    final otpController = TextEditingController();

    String? verificationId;
    bool otpSent = false;
    bool loading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> sendOtp() async {
              if (!(formKey.currentState?.validate() ?? false)) return;

              final phoneNumber = _normalizePhoneNumber(phoneController.text);

              setStateDialog(() => loading = true);

              await fb_auth.FirebaseAuth.instance.verifyPhoneNumber(
                phoneNumber: phoneNumber,
                verificationCompleted: (credential) async {
                  final userCredential =
                      await fb_auth.FirebaseAuth.instance.signInWithCredential(
                    credential,
                  );

                  final firebaseIdToken =
                      await userCredential.user?.getIdToken();

                  if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
                    return;
                  }

                  if (!mounted) return;

                  context.read<AuthBloc>().add(
                        VerifyPhoneEvent(firebaseIdToken),
                      );

                  Navigator.pop(dialogContext);
                  _phoneDialogShown = false;
                },
                verificationFailed: (e) {
                  setStateDialog(() => loading = false);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Gửi OTP thất bại: ${e.message}"),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                },
                codeSent: (vid, _) {
                  verificationId = vid;
                  setStateDialog(() {
                    otpSent = true;
                    loading = false;
                  });
                },
                codeAutoRetrievalTimeout: (vid) {
                  verificationId = vid;
                },
              );
            }

            Future<void> confirmOtp() async {
              if (verificationId == null) return;

              try {
                setStateDialog(() => loading = true);

                final credential = fb_auth.PhoneAuthProvider.credential(
                  verificationId: verificationId!,
                  smsCode: otpController.text.trim(),
                );

                final userCredential =
                    await fb_auth.FirebaseAuth.instance.signInWithCredential(
                  credential,
                );

                final firebaseIdToken = await userCredential.user?.getIdToken();

                if (firebaseIdToken == null || firebaseIdToken.isEmpty) return;

                if (!mounted) return;

                context.read<AuthBloc>().add(
                      VerifyPhoneEvent(firebaseIdToken),
                    );

                Navigator.pop(dialogContext);
                _phoneDialogShown = false;
              } catch (e) {
                setStateDialog(() => loading = false);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("OTP không chính xác"),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: const Text("Xác minh số điện thoại"),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      enabled: !otpSent && !loading,
                      readOnly: otpSent || loading,
                      decoration: const InputDecoration(
                        labelText: "Số điện thoại",
                      ),
                      validator: (v) {
                        if ((v ?? '').trim().isEmpty) {
                          return "Vui lòng nhập số điện thoại";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    if (otpSent)
                      TextFormField(
                        controller: otpController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Nhập OTP",
                        ),
                        validator: (v) {
                          if ((v ?? '').trim().isEmpty) {
                            return "Vui lòng nhập OTP";
                          }
                          return null;
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _phoneDialogShown = false;
                  },
                  child: const Text("Hủy"),
                ),
                TextButton(
                  onPressed: loading ? null : (otpSent ? confirmOtp : sendOtp),
                  child: Text(
                    loading
                        ? "Đang xử lý..."
                        : otpSent
                            ? "Xác nhận"
                            : "Gửi OTP",
                  ),
                ),
              ],
            );
          },
        );
      },
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
              if (state is AuthAuthenticated) {
                final needPhone = _needsPhoneVerification(state.user);

                if (needPhone) {
                  if (!_phoneDialogShown) {
                    _phoneDialogShown = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      _showVerifyPhoneDialog();
                    });
                  }
                  return;
                }

                _phoneDialogShown = false;

                if (widget.redirectPath != null) {
                  context.go(widget.redirectPath!);
                } else {
                  context.go('/');
                }
              }

              if (state is AuthSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.surface,
                  ),
                );
              }

              if (state is AuthError) {
                final message = state.message;

                if (message.startsWith("REQUIRE_LINK_CONFIRM:")) {
                  final confirmMessage =
                      message.replaceFirst("REQUIRE_LINK_CONFIRM:", "").trim();

                  if (_isShowingLinkDialog) return;
                  _isShowingLinkDialog = true;

                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    if (!mounted) return;

                    final shouldLink = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (dialogContext) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              title: const Text("Liên kết tài khoản"),
                              content: Text(confirmMessage),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext, false);
                                  },
                                  child: const Text("Hủy"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext, true);
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            );
                          },
                        ) ??
                        false;

                    _isShowingLinkDialog = false;

                    if (shouldLink && _pendingFirebaseIdToken != null) {
                      if (!mounted) return;

                      context.read<AuthBloc>().add(
                            LoginWithFirebaseEvent(
                              idToken: _pendingFirebaseIdToken!,
                              isStoreOwnerApp: false,
                              linkToExistingAccount: true,
                            ),
                          );
                    }
                  });

                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
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
                          _backButton(),
                          const SizedBox(height: 16),
                          Center(
                            child: Container(
                              width: 170,
                              height: 170,
                              decoration: BoxDecoration(
                                gradient: AppDecorations.heroGradient,
                                shape: BoxShape.circle,
                                boxShadow: AppDecorations.avatarShadow,
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  'https://res.cloudinary.com/dbie57o9w/image/upload/v1774090680/ae61e167-0891-4498-8167-c2191898f6da.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.favorite,
                                    size: 72,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              "Chào mừng trở lại",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.pageTitle,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              "Đăng nhập để tiếp tục trải nghiệm dịch vụ của bạn",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMuted,
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
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<AuthBloc>(),
                                      child: const ForgotPasswordPage(),
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                "Quên mật khẩu?",
                                style: AppTextStyles.bodyMuted.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              if (state is AuthLoading) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                );
                              }

                              return SizedBox(
                                width: double.infinity,
                                child: _primaryButton(
                                  text: "Đăng nhập",
                                  onTap: _login,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _rowOrDivider(),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: _googleButton(
                              onTap: _loginWithGoogle,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: _secondaryButton(
                              text: "Đăng ký",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: context.read<AuthBloc>(),
                                      child: const RegisterPage(),
                                    ),
                                  ),
                                );
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
      borderRadius: BorderRadius.circular(14),
      onTap: () => context.go('/'),
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

  Widget _rowOrDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            thickness: 1,
            color: AppColors.borderSoft,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "hoặc",
            style: AppTextStyles.bodyMuted.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            thickness: 1,
            color: AppColors.borderSoft,
          ),
        ),
      ],
    );
  }

  Widget _googleButton({
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
              Image.network(
                'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                width: 20,
                height: 20,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.g_mobiledata_rounded,
                  size: 24,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Google",
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
        boxShadow: AppDecorations.softShadow,
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        validator: validator,
        onFieldSubmitted: (_) => onSubmitted(),
        style: AppTextStyles.body.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: AppTextStyles.bodyMuted,
          prefixIcon: Icon(icon, color: AppColors.primary),
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

  void _login() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      _focusFirstInvalidField();
      return;
    }

    String input = _emailOrPhoneController.text.trim();

    final isPhone = RegExp(r'^[0-9+]+$').hasMatch(input);

    if (isPhone) {
      input = _normalizePhoneNumber(input);
    }

    final password = _passwordController.text.trim();

    context.read<AuthBloc>().add(
          LoginEvent(
            email: input,
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

  Future<void> _loginWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId:
            '361936167810-bs47k71bsrvrcg8bt0d3780focaif9b7.apps.googleusercontent.com',
      );

      await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential =
          await fb_auth.FirebaseAuth.instance.signInWithCredential(credential);

      final firebaseIdToken = await userCredential.user?.getIdToken();

      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        throw Exception("Không lấy được Firebase ID token");
      }

      _pendingFirebaseIdToken = firebaseIdToken;

      if (!mounted) return;
      context.read<AuthBloc>().add(
            LoginWithFirebaseEvent(
              idToken: firebaseIdToken,
              isStoreOwnerApp: false,
            ),
          );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đăng nhập Google thất bại: $e"),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Widget _primaryButton({
    required String text,
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
                AppColors.placeholderStart,
                AppColors.placeholderEnd,
              ],
            ),
            boxShadow: AppDecorations.cardShadow,
          ),
          child: Center(
            child: Text(
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

  Widget _secondaryButton({
    required String text,
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
          child: Center(
            child: Text(
              text,
              style: AppTextStyles.bodyMuted.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
