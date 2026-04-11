import 'dart:async';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../features/notification/services/notification_api.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('🌙 [Background/Killed] Nhận thông báo: ${message.notification?.title}');
}

class FirebaseMessagingService {
  static final StreamController<void> _onNotificationArrived = StreamController.broadcast();
  static Stream<void> get onNotificationArrived => _onNotificationArrived.stream;

  static Future<void> init() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true, badge: true, sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('✅ Người dùng ĐÃ CẤP QUYỀN nhận thông báo');
      
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true,
      );

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      await _uploadTokenToServer(messaging);

      messaging.onTokenRefresh.listen((newToken) async {
        log("🔄 FCM Token đã bị làm mới: $newToken");
        try {
          await NotificationApi.updateFcmToken(newToken);
        } catch (e) {
          log("⚠️ Lỗi khi cập nhật Token mới: $e");
        }
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log('📩 [Foreground] Nhận thông báo: ${message.notification?.title}');
        _onNotificationArrived.add(null);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log('👆 Bấm vào banner thông báo lúc app chạy ngầm!');
      });

    } else {
      log('❌ Người dùng TỪ CHỐI cấp quyền thông báo');
    }
  }

  static Future<void> _uploadTokenToServer(FirebaseMessaging messaging) async {
    try {
      String? token = await messaging.getToken();
      if (token != null) {
        log("🔑 FCM Token của thiết bị: $token");
        await NotificationApi.updateFcmToken(token);
      }
    } catch (e) {
      log("⚠️ Chưa thể gửi Token lên Server (Có thể do chưa đăng nhập): $e");
    }
  }
}