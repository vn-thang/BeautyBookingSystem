import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_store/features/service/widgets/shared_service_widgets.dart';
import 'package:mobile_store/features/store/screens/store_setup_screen.dart';
import 'package:mobile_store/shared/widgets/buttons/app_buttons.dart';
import 'package:mobile_store/shared/widgets/inputs/app_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimens.dart';
import '../services/auth_service.dart';

class SocialPhoneHelper {
  
  static void showPhoneInputDialog({
    required BuildContext context,
    required Function(bool) onLoading,
    required Function(String) onError,
  }) {
    final socialPhoneController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          ),
          title: Text(
            'Bổ sung Số điện thoại', 
            textAlign: TextAlign.center,
            style: AppTextStyles.heading1.copyWith(fontSize: 20), 
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Để mở cửa hàng, bạn cần cung cấp số điện thoại liên lạc.', 
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyText,
              ),
              const SizedBox(height: AppDimens.paddingMedium), 
              
              AppTextField(
                hint: 'Nhập số điện thoại',
                icon: Icons.phone_outlined,
                controller: socialPhoneController,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppDimens.paddingMedium),
              
              AppPrimaryButton(
                text: 'NHẬN MÃ OTP',
                onPressed: () {
                  final phone = socialPhoneController.text.trim();
                  if (phone.isEmpty) return;
                  Navigator.pop(ctx);
                  _verifyPhone(context, phone, onLoading, onError);
                },
              ),
              
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Hủy bỏ', 
                  style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _verifyPhone(
    BuildContext context, String phone, Function(bool) onLoading, Function(String) onError
  ) async {
    onLoading(true);
    String phoneStr = phone.startsWith('0') ? '+84${phone.substring(1)}' : phone;

    try {
      await FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneStr,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _linkPhoneAndCallBackend(context, credential, onLoading, onError);
        },
        verificationFailed: (FirebaseAuthException e) {
          onLoading(false);
          onError(e.message ?? 'Lỗi gửi SMS.');
        },
        codeSent: (String verificationId, int? resendToken) {
          onLoading(false);
          _showOtpDialog(context, verificationId, phoneStr, onLoading, onError);
        },
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      onLoading(false);
      onError('Lỗi hệ thống: $e');
    }
  }

  static void _showOtpDialog(
    BuildContext context, String verificationId, String phoneStr, Function(bool) onLoading, Function(String) onError
  ) {
    final otpController = TextEditingController();
    bool isVerifying = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              ),
              title: Text(
                'Xác thực OTP', 
                textAlign: TextAlign.center, 
                style: AppTextStyles.heading1.copyWith(fontSize: 20),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Mã 6 số đã được gửi đến $phoneStr',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyText,
                    ),
                    const SizedBox(height: AppDimens.paddingMedium),
                    
                    AppTextField(
                      hint: 'Nhập mã OTP',
                      icon: Icons.security_outlined,
                      controller: otpController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppDimens.paddingMedium),
                    
                    AppPrimaryButton(
                      text: 'XÁC NHẬN & TẠO CỬA HÀNG',
                      isLoading: isVerifying,
                      onPressed: () async {
                        if (otpController.text.length < 6) return;
                        setDialogState(() => isVerifying = true);
                        try {
                          final credential = PhoneAuthProvider.credential(
                            verificationId: verificationId,
                            smsCode: otpController.text.trim(),
                          );
                          Navigator.pop(ctx);
                          await _linkPhoneAndCallBackend(context, credential, onLoading, onError);
                        } catch (e) {
                          setDialogState(() => isVerifying = false);
                          if (ctx.mounted) {
                            SnackBarHelper.showError(ctx, 'Mã OTP không hợp lệ hoặc đã hết hạn.');
                          }
                        }
                      },
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

  static Future<void> _linkPhoneAndCallBackend(
    BuildContext context, PhoneAuthCredential credential, Function(bool) onLoading, Function(String) onError
  ) async {
    try {
      onLoading(true);

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("Phiên đăng nhập Google đã hết hạn.");

      final userCredential = await currentUser.linkWithCredential(credential);
      await userCredential.user?.reload();
      
      final newToken = await FirebaseAuth.instance.currentUser?.getIdToken(true);
      if (newToken == null) throw Exception("Không lấy được mã xác thực mới.");

      final result = await AuthService.loginWithFirebase(
        idToken: newToken, 
        isStoreOwnerApp: true
      );

      if (!context.mounted) return;

      if (result.isSuccess) {
        SnackBarHelper.showSuccess(context, 'Tạo tài khoản cửa hàng thành công!');
        
        final status = result.data?.storeStatus ?? 'Incomplete';
        if (status == 'Incomplete') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StoreSetupScreen())); 
        }
      } else {
      onError(result.errorMessage ?? 'Đã xảy ra lỗi không xác định, vui lòng thử lại.');
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = e.message ?? "Lỗi xác thực.";
      if (e.code == 'credential-already-in-use') {
        errorMsg = "Số điện thoại này đã được liên kết với một tài khoản khác!";
      } else if (e.code == 'invalid-verification-code') {
        errorMsg = "Mã OTP không chính xác!";
      }
      onError(errorMsg);
    } catch (e) {
      onError("Lỗi tạo tài khoản: $e");
    } finally {
      onLoading(false);
    }
  }
}