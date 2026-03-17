import 'dart:async';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../features/notification/services/notification_api.dart';

// Dùng để nhận thông báo khi App đã bị vuốt tắt hoàn toàn (Killed/Terminated)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('🌙 [Background/Killed] Nhận thông báo: ${message.notification?.title}');
}

class FirebaseMessagingService {
  // Tạo 1 Stream (kênh phát sóng) để báo cho UI biết khi có thông báo mới tới
  static final StreamController<void> _onNotificationArrived = StreamController.broadcast();
  static Stream<void> get onNotificationArrived => _onNotificationArrived.stream;

  static Future<void> init() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 1. Xin quyền người dùng hiển thị thông báo
    NotificationSettings settings = await messaging.requestPermission(
      alert: true, badge: true, sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('✅ Người dùng ĐÃ CẤP QUYỀN nhận thông báo');
      
      // 2. Cấu hình cho iOS: Hiển thị popup ngay cả khi đang mở app
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true, badge: true, sound: true,
      );

      // 3. Đăng ký hàm xử lý khi App bị tắt hẳn (Background/Terminated)
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 4. Lấy FCM Token và gửi lên Server
      await _uploadTokenToServer(messaging);

      // 5. Lắng nghe sự kiện: Nếu Token bị Firebase làm mới thì tự động gửi lại
      messaging.onTokenRefresh.listen((newToken) async {
        log("🔄 FCM Token đã bị làm mới: $newToken");
        try {
          await NotificationApi.updateFcmToken(newToken);
        } catch (e) {
          log("⚠️ Lỗi khi cập nhật Token mới: $e");
        }
      });

      // 6. Lắng nghe thông báo khi app ĐANG MỞ (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log('📩 [Foreground] Nhận thông báo: ${message.notification?.title}');
        // Bắn tín hiệu ra ngoài để Navbar biết mà +1 vào cái chuông đỏ
        _onNotificationArrived.add(null);
      });

      // 7. Xử lý khi người dùng bấm vào banner thông báo lúc app chạy ngầm
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log('👆 Bấm vào banner thông báo lúc app chạy ngầm!');
        // (Tùy chọn) Chuyển hướng người dùng ở đây
      });

    } else {
      log('❌ Người dùng TỪ CHỐI cấp quyền thông báo');
    }
  }

  // Hàm nội bộ để lấy Token thiết bị và gọi API cập nhật
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