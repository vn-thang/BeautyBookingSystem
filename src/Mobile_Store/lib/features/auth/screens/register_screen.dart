import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_store/core/screens/custom_webview_screen.dart';
import 'package:mobile_store/features/auth/utils/social_auth_helper.dart';
import 'package:mobile_store/features/auth/utils/social_phone_helper.dart';
import 'package:mobile_store/features/home/screens/main_screen.dart';
import 'package:mobile_store/features/store/screens/store_setup_screen.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';
import '../../../shared/widgets/buttons/app_buttons.dart';
import '../../../shared/widgets/feedback/app_error_box.dart';
import '../../../shared/widgets/feedback/snackbar_helper.dart';
import '../widgets/auth_components.dart';
import '../services/auth_service.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _serverErrorMessage;
  bool _isAgreed = false;
  late TapGestureRecognizer _termsRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer(); 
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _termsRecognizer.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_serverErrorMessage != null) {
      setState(() {
        _serverErrorMessage = null;
      });
    }
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

  Future<void> _handleRegister() async {
    _clearError();
    if (!_formKey.currentState!.validate()) return;

    if (!_isAgreed) {
      SnackBarHelper.showError(context, 'Vui lòng đồng ý với Chính sách & điều khoản!');
      return;
    }

    setState(() => _isLoading = true);

    String phoneStr = _phoneController.text.trim();
    if (phoneStr.startsWith('0')) {
      phoneStr = '+84${phoneStr.substring(1)}';
    }

    try {
      await FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneStr,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _processRegistrationWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
            _serverErrorMessage = e.message ?? 'Gửi mã xác thực thất bại.';
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() => _isLoading = false);
          _showOtpDialog(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _serverErrorMessage = 'Lỗi hệ thống: $e';
      });
    }
  }

  void _showOtpDialog(String verificationId) {
    final otpController = TextEditingController();
    bool isVerifying = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Xác thực số điện thoại',
                style: AppTextStyles.heading1.copyWith(fontSize: 20, color: AppColors.authTextTitle),
                textAlign: TextAlign.center,
              ),
              content: SingleChildScrollView(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Mã OTP gồm 6 chữ số đã được gửi đến ${_phoneController.text.trim()}',
                    style: AppTextStyles.bodyText.copyWith(color: AppColors.authTextBody),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    hint: 'Nhập mã OTP',
                    icon: Icons.security_outlined,
                    controller: otpController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  AppPrimaryButton(
                    text: 'XÁC NHẬN OTP',
                    isLoading: isVerifying,
                    onPressed: () async {
                      final code = otpController.text.trim();
                      if (code.isEmpty || code.length < 6) {
                        SnackBarHelper.showError(ctx, 'Vui lòng nhập đủ 6 số OTP');
                        return;
                      }

                      setDialogState(() => isVerifying = true);
                      try {
                        final credential = PhoneAuthProvider.credential(
                          verificationId: verificationId,
                          smsCode: code,
                        );
                        
                        Navigator.pop(ctx); 
                        setState(() => _isLoading = true);
                        
                        await _processRegistrationWithCredential(credential);
                        
                      } on FirebaseAuthException catch (_) {
                        setDialogState(() => isVerifying = false);
                        if (ctx.mounted) {
                        SnackBarHelper.showError(ctx, 'Mã OTP không hợp lệ hoặc đã hết hạn.');
                        }
                      } catch (e) {
                        setDialogState(() => isVerifying = false);
                        if (ctx.mounted) {
                        SnackBarHelper.showError(ctx, 'Có lỗi xảy ra: $e');
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: isVerifying ? null : () => Navigator.pop(ctx),
                    child: const Text('Hủy bỏ', style: TextStyle(color: AppColors.authTextSub)),
                  ),
                ],
              ),
            ),
            );
          },
        );
      },
    );
  }

  Future<void> _processRegistrationWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();

      if (idToken == null) {
        throw Exception('Không lấy được mã xác thực an toàn từ hệ thống.');
      }

      final result = await AuthService.registerPartner(
        _ownerNameController.text.trim(),
        _phoneController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        idToken,
      );

      if (!mounted) return;

      if (result.isSuccess) {
        SnackBarHelper.showSuccess(context, 'Đăng ký cửa hàng thành công! Vui lòng đăng nhập.');
        Navigator.pop(context);
      } else {
        setState(() => _serverErrorMessage = result.errorMessage);
      }
    } catch (e) {
      setState(() => _serverErrorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleSocialRegister(String provider) {
    _clearError();
    
    SocialAuthHelper.processSocialAuth(
      context: context,
      provider: provider,
      onLoading: (loading) {
        if (mounted) setState(() => _isLoading = loading);
      },
      onSuccess: (loginData) {
        if (!mounted) return;
        if (loginData.role != 'StoreOwner') {
          setState(() => _serverErrorMessage = "Ứng dụng này chỉ dành cho cửa hàng!");
          return; 
        }

        final status = loginData.storeStatus ?? 'Incomplete';
        if (status == 'Incomplete') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StoreSetupScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
        }
      },
      onError: (String error) {
        if (!mounted) return;

        if (error.contains("REQUIRE_PHONE_VERIFICATION")) {
          // GỌI HELPER Ở ĐÂY
          SocialPhoneHelper.showPhoneInputDialog(
            context: context,
            onLoading: (loading) {
              if (mounted) setState(() => _isLoading = loading);
            },
            onError: (errMsg) {
              if (mounted) setState(() => _serverErrorMessage = errMsg);
            },
          );
        } else {
          setState(() => _serverErrorMessage = error);
        }
      }
    );
  }
  void _handleSocialLogin(String provider) {
    _clearError();
    SocialAuthHelper.processSocialAuth(
      context: context,
      provider: provider,
      onLoading: (loading) {
        if (mounted) setState(() => _isLoading = loading);
      },
      onSuccess: (loginData) {
        if (!mounted) return;
  
        if (loginData.role != 'StoreOwner') {
          setState(() => _serverErrorMessage = "Tài khoản không có quyền truy cập. Ứng dụng này chỉ dành cho cửa hàng!");
          return; 
        }

        final status = loginData.storeStatus ?? 'Incomplete';
        if (status == 'Incomplete') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StoreSetupScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
        }
      },
      onError: (String error) {
        if (!mounted) return;
        
        if (error.contains("REQUIRE_PHONE_VERIFICATION")) {
          // GỌI HELPER Ở ĐÂY
          SocialPhoneHelper.showPhoneInputDialog(
            context: context,
            onLoading: (loading) {
              if (mounted) setState(() => _isLoading = loading);
            },
            onError: (errMsg) {
              if (mounted) setState(() => _serverErrorMessage = errMsg);
            },
          );
        } else {
          setState(() => _serverErrorMessage = error);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _termsRecognizer.onTap = () {
      _openTermsWebPage(context);
    };

    return Scaffold(
      body: AuthGlassBackground(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Đăng ký đối tác',
                style: AppTextStyles.heading1.copyWith(
                  fontSize: 24,
                  color: AppColors.authTextTitle,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Tạo tài khoản cửa hàng của bạn',
                style: AppTextStyles.bodyText.copyWith(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 15),
              AppTextField(
                hint: 'Họ và tên chủ tiệm',
                icon: Icons.person_outline,
                controller: _ownerNameController,
                validator: (val) => FormValidators.requiredField(val, 'Vui lòng nhập họ tên'),
                onChanged: (_) => _clearError(),
              ),
              const SizedBox(height: 14),

              AppTextField(
                hint: 'Số điện thoại',
                icon: Icons.phone_outlined,
                controller: _phoneController,
                validator: FormValidators.phone,
                onChanged: (_) => _clearError(),
              ),
              const SizedBox(height: 14),

              AppTextField(
                hint: 'Email',
                icon: Icons.email_outlined,
                controller: _emailController,
                validator: FormValidators.email,
                onChanged: (_) => _clearError(),
              ),
              const SizedBox(height: 14),

              AppTextField(
                hint: 'Mật khẩu',
                icon: Icons.lock_outline,
                controller: _passwordController,
                isPassword: true,
                validator: (val) => FormValidators.password(val),
                onChanged: (_) => _clearError(),
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
                      activeColor: AppColors.authLink,
                      side: const BorderSide(color: AppColors.authTextBody),
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
                          style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.authTextBody,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: 'Chính sách & điều khoản',
                              style: const TextStyle(
                                color: AppColors.authLink,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: _termsRecognizer, 
                            ),
                            const TextSpan(text: ' dịch vụ.'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (_serverErrorMessage != null) ...[
                const SizedBox(height: 14),
                AppErrorBox(errorMessage: _serverErrorMessage!),
              ],
              const SizedBox(height: 15),

              AppPrimaryButton(
                text: 'ĐĂNG KÝ CỬA HÀNG',
                isLoading: _isLoading,
                onPressed: _handleRegister,
                color: const Color(0xFFFF758C),
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.authTextSub.withValues(alpha: 0.3), thickness: 1)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Hoặc tiếp tục với', 
                      style: TextStyle(color: AppColors.authTextSub, fontSize: 12),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.authTextSub.withValues(alpha: 0.3), thickness: 1)),
                ],
              ),
              const SizedBox(height: 15),
          
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialIconButton(
                  icon: Image.asset(
                    'assets/images/facebook_logo.png', 
                    width: 45, 
                    height: 45,
                    fit: BoxFit.contain,
                  ),
                  onTap: () => _handleSocialLogin('Facebook'),
                ),
                  const SizedBox(width: 25), 
               SocialIconButton(
                icon: Image.asset(
                  'assets/images/google_logo.png',
                  width: 45, 
                  height: 45,
                  fit: BoxFit.contain,
                ),
                onTap: () => _handleSocialLogin('Google'),
              ),
                ],
              ),
            
const SizedBox(height: 20),
              Text(
                'Đã có tài khoản đối tác?',
                style: AppTextStyles.bodyText.copyWith(color: AppColors.authTextBody, fontSize: 13),
              ),
              const SizedBox(height: 10),
              AppOutlineButton(
                text: 'ĐĂNG NHẬP NGAY',
                color: AppColors.authLink,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
