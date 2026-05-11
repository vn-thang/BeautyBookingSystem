import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/screens/custom_webview_screen.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

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

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool obscure = true;
  bool _isAgreed = false;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  bool _phoneVerified = false;
  String? _verificationId;
  String? _firebaseIdToken;
    String? _pendingFirebaseIdToken;

  late TapGestureRecognizer _termsRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () {
        _openTermsWebPage(context);
      };
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _termsRecognizer.dispose();
    super.dispose();
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

  String _toE164VN(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0') && digits.length == 10) {
      return '+84${digits.substring(1)}';
    }
    if (digits.startsWith('84') && digits.length == 11) {
      return '+$digits';
    }
    return '+$digits';
  }

  String _firebaseOtpErrorToVietnamese(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-verification-code':
        return 'Mã OTP không đúng';
      case 'session-expired':
        return 'Mã OTP đã hết hạn, vui lòng gửi lại mã';
      case 'too-many-requests':
        return 'Bạn thao tác quá nhiều lần, vui lòng thử lại sau';
      default:
        return 'Xác minh OTP thất bại';
    }
  }

  Future<void> _sendOtpToPhone() async {
    final phone = phoneController.text.trim();
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length != 10 || !digitsOnly.startsWith('0')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập số điện thoại hợp lệ trước"),
        ),
      );
      return;
    }

    setState(() {
      _isSendingOtp = true;
      _phoneVerified = false;
      _firebaseIdToken = null;
      _verificationId = null;
    });

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: _toE164VN(phone),
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final userCred =
                await _firebaseAuth.signInWithCredential(credential);
            final token = await userCred.user?.getIdToken(true);

            if (!mounted) return;
            setState(() {
              _phoneVerified = true;
              _firebaseIdToken = token;
              _isSendingOtp = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Đã xác minh số điện thoại")),
            );
          } catch (e) {
            if (!mounted) return;
            setState(() => _isSendingOtp = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Xác minh tự động thất bại: $e")),
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() => _isSendingOtp = false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? "Không gửi được OTP")),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _isSendingOtp = false;
          });

          _showOtpDialog();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!mounted) return;
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSendingOtp = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi gửi OTP: $e")),
      );
    }
  }

  Future<void> _showOtpDialog() async {
    if (!mounted || _verificationId == null) return;

    setState(() => _isVerifyingOtp = true);

    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return _OtpDialog(
            firebaseAuth: _firebaseAuth,
            verificationId: _verificationId!,
            onVerified: (token) {
              if (!mounted) return;
              setState(() {
                _phoneVerified = true;
                _firebaseIdToken = token;
              });
            },
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isVerifyingOtp = false);
      }
    }
  }

  void _register() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_phoneVerified || _firebaseIdToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng xác minh số điện thoại trước khi đăng ký"),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (!_isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng đồng ý với Chính sách & điều khoản!"),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
          RegisterEvent(
            fullName: fullNameController.text.trim(),
            phone: phoneController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text,
            firebaseIdToken: _firebaseIdToken!,
          ),
        );
  }
   Future<void> _loginWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId:
            '334394781529-p9mug7mcegasdavsjgmo3mft9jqqagvh.apps.googleusercontent.com',
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
    } catch (e, stacktrace) {
      if (!mounted) return;
debugPrint("========== GOOGLE LOGIN ERROR ==========");
  debugPrint("Error: $e");
  debugPrint("Stacktrace: $stacktrace");
  debugPrint("========================================");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Đăng nhập Google thất bại: $e"),
          backgroundColor: AppColors.danger,
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

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                });
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
                      color: AppColors.surface.withValues(alpha: 0.88),
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
                                          AppColors.surface.withValues(alpha: 0.03),
                                          AppColors.placeholderEnd
                                              .withValues(alpha: 0.25),
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
                                  if (v.isEmpty) return "Nhập họ tên";
                                  if (v.length < 2) return "Họ tên quá ngắn";
                                  final nameRegex =
                                      RegExp(r"^[A-Za-zÀ-ỹà-ỹ\s'.-]+$");
                                  if (!nameRegex.hasMatch(v)) {
                                    return "Họ tên không hợp lệ";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              _buildPhoneWithOtpButton(),
                              const SizedBox(height: 14),
                              _buildField(
                                controller: emailController,
                                label: "Email",
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  final v = value?.trim() ?? '';
                                  if (v.isEmpty) return "Nhập email";

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
                                  if (v.isEmpty) return "Nhập mật khẩu";
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
                              const SizedBox(height: 14),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _isAgreed,
                                      activeColor: AppColors.primary,
                                      side: const BorderSide(
                                        color: AppColors.borderSoft,
                                      ),
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
                                          style: AppTextStyles.bodyMuted,
                                          children: [
                                            TextSpan(
                                              text: 'Chính sách & điều khoản',
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              recognizer: _termsRecognizer,
                                            ),
                                            const TextSpan(
                                              text: ' dịch vụ của hệ thống.',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
                            const SizedBox(height: 24), 
                              const SizedBox(height: 16),
                          _rowOrDivider(),
                          const SizedBox(height: 24),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _facebookButton(
                                onTap: () {
                                  // TODO: Thêm hàm xử lý đăng nhập Facebook ở đây
                                },
                              ),
                              const SizedBox(width: 32),
                              _googleButton(
                                onTap: _loginWithGoogle,
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                        
                          Center(
                            child: Text(
                              "Đã có tài khoản?",
                              style: AppTextStyles.bodyMuted.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12), 
                          
                          SizedBox(
                            width: double.infinity,
                            child: _secondaryButton(
                              text: "Đăng nhập ngay",
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

  Widget _buildPhoneWithOtpButton() {
    return _buildField(
      controller: phoneController,
      label: "Số điện thoại",
      icon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      onChanged: (_) {
        if (_phoneVerified) {
          setState(() {
            _phoneVerified = false;
            _firebaseIdToken = null;
          });
        }
      },
      validator: (value) {
        final v = value?.trim() ?? '';
        if (v.isEmpty) return "Nhập số điện thoại";

        final digitsOnly = v.replaceAll(RegExp(r'\D'), '');
        if (digitsOnly.length != 10) {
          return "Số điện thoại phải có 10 chữ số";
        }

        if (!digitsOnly.startsWith('0')) {
          return "Số điện thoại không hợp lệ";
        }

        return null;
      },
      suffixIcon: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: TextButton(
          onPressed: (_isSendingOtp || _isVerifyingOtp || _phoneVerified)
              ? null
              : _sendOtpToPhone,
          style: TextButton.styleFrom(
            foregroundColor: _phoneVerified ? Colors.green : AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: _isSendingOtp
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  _phoneVerified ? "Đã xác minh" : "Xác minh",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _phoneVerified ? Colors.green : AppColors.primary,
                  ),
                ),
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
            "Hoặc tiếp tục với",
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
   Widget _facebookButton({required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), 
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.facebook,
              color: Color(0xFF1877F2), 
              size: 48, 
            ),
          ),
        ),
      ),
    );
  }
  Widget _googleButton({required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
              width: 26,
              height: 26,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.g_mobiledata_rounded,
                size: 32,
                color: AppColors.primary,
              ),
            ),
          ),
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
    ValueChanged<String>? onChanged,
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
        onChanged: onChanged,
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

class _OtpDialog extends StatefulWidget {
  final FirebaseAuth firebaseAuth;
  final String verificationId;
  final ValueChanged<String?> onVerified;

  const _OtpDialog({
    required this.firebaseAuth,
    required this.verificationId,
    required this.onVerified,
  });

  @override
  State<_OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<_OtpDialog> {
  final TextEditingController _otpController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _confirmOtp() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP không hợp lệ")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      final userCred =
          await widget.firebaseAuth.signInWithCredential(credential);
      final token = await userCred.user?.getIdToken(true);

      if (!mounted) return;

      widget.onVerified(token);

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      final message = _mapFirebaseOtpError(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Xác minh thất bại: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _mapFirebaseOtpError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-verification-code':
        return 'Mã OTP không đúng';
      case 'session-expired':
        return 'Mã OTP đã hết hạn, vui lòng gửi lại mã';
      case 'too-many-requests':
        return 'Bạn thao tác quá nhiều lần, vui lòng thử lại sau';
      default:
        return 'Xác minh OTP thất bại';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Nhập mã OTP"),
      content: TextField(
        controller: _otpController,
        keyboardType: TextInputType.number,
        maxLength: 6,
        decoration: const InputDecoration(
          hintText: "Nhập 6 chữ số OTP",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Hủy"),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _confirmOtp,
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Xác nhận"),
        ),
      ],
    );
  }
}
