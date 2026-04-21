import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../services/auth_service.dart';
import '../models/login_response_model.dart';

class SocialAuthHelper {
  static Future<void> processSocialAuth({
    required BuildContext context,
    required String provider,
    required Function(bool) onLoading,
    required Function(LoginResponseModel) onSuccess,
    required Function(String) onError, 
  }) async {
    onLoading(true);
    try {
      String? idToken;

      if (provider == 'Google') {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          onLoading(false);
          return;
        }
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        idToken = await userCredential.user?.getIdToken();
      } else {
        final LoginResult fbResult = await FacebookAuth.instance.login();
        if (fbResult.status != LoginStatus.success) {
          onLoading(false);
          return;
        }
        final credential = FacebookAuthProvider.credential(fbResult.accessToken!.token);
        final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        idToken = await userCredential.user?.getIdToken();
      }

      if (!context.mounted) return;

      if (idToken != null) {
        await _sendTokenToBackend(
          context: context,
          idToken: idToken,
          onSuccess: onSuccess,
          onError: onError,
        );
      }
    } catch (e) {
      if (context.mounted) {
        onError("Lỗi $provider: $e");
      }
    } finally {
      onLoading(false);
    }
  }

  static Future<void> _sendTokenToBackend({
    required BuildContext context,
    required String idToken,
    required Function(LoginResponseModel) onSuccess,
    required Function(String) onError, 
    bool linkAccount = false,
  }) async {
    String? fcmToken;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
    } catch (_) {}

    final result = await AuthService.loginWithFirebase(
      idToken: idToken,
      fcmToken: fcmToken,
      linkToExistingAccount: linkAccount,
      isStoreOwnerApp: true, 
    );

    if (!context.mounted) return;

    if (result.isSuccess) {
      onSuccess(result.data!);
    } else {
      if (result.errorMessage!.contains("REQUIRE_LINK_CONFIRM")) {
        _showLinkDialog(context, idToken, onSuccess, onError);
      } else {
        onError(result.errorMessage!); 
      }
    }
  }

  static void _showLinkDialog(
      BuildContext context, 
      String idToken, 
      Function(LoginResponseModel) onSuccess,
      Function(String) onError) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Liên kết tài khoản"),
        content: const Text("Email này đã có tài khoản. Bạn có muốn liên kết với tài khoản hiện tại không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (context.mounted) {
                _sendTokenToBackend(
                  context: context, 
                  idToken: idToken, 
                  onSuccess: onSuccess, 
                  onError: onError, 
                  linkAccount: true
                );
              }
            },
            child: const Text("Đồng ý"),
          ),
        ],
      ),
    );
  }
}