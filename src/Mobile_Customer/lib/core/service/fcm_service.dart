import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<String?> initAndGetToken() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    return _messaging.getToken();
  }

  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;
}
