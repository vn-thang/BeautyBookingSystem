// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:mobile_store/core/network/api_client.dart';
// import 'package:mobile_store/features/home/screens/main_screen.dart';
// import 'package:mobile_store/shared/token_storage.dart';
// import 'core/constant/global_keys.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:mobile_store/features/auth/screens/login_screen.dart';

// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
// }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await initializeDateFormatting('vi_VN', null);
//   await Firebase.initializeApp();

//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   String firstScreen = '/login';

//   final accessToken = await TokenStorage.getAccessToken();
//   final refreshToken = await TokenStorage.getRefreshToken();

//   if (accessToken != null && accessToken.isNotEmpty) {
//     try {
//       bool isExpired = JwtDecoder.isExpired(accessToken);

//       if (!isExpired) {
//         debugPrint("✅ Access Token còn hạn, vào Home.");
//         firstScreen = '/home';
//       } else {
//         debugPrint(
//           "⚠️ Access Token đã hết hạn. Đang kiểm tra Refresh Token...",
//         );

//         if (refreshToken != null && refreshToken.isNotEmpty) {
//           bool isRefreshSuccess = await ApiClient.refreshToken();

//           if (isRefreshSuccess) {
//             firstScreen = '/home';
//           } else {
//             debugPrint("❌ Refresh Token thất bại. Xóa dữ liệu và về Login.");
//             await TokenStorage.clearTokens();
//             firstScreen = '/login';
//           }
//         } else {
//           await TokenStorage.clearTokens();
//           firstScreen = '/login';
//         }
//       }
//     } catch (e) {
//       debugPrint("❌ Lỗi định dạng Token: $e");
//       await TokenStorage.clearTokens();
//       firstScreen = '/login';
//     }
//   }

//   runApp(StoreAdminApp(initialRoute: firstScreen));
// }

// class StoreAdminApp extends StatelessWidget {
//   final String initialRoute;

//   const StoreAdminApp({super.key, required this.initialRoute});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       title: 'Beauty Booking',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(primarySwatch: Colors.pink, fontFamily: 'Roboto'),
//       initialRoute: initialRoute,
//       routes: {
//         '/login': (context) => const LoginScreen(),
//         '/home': (context) => const MainScreen(),
//       },
//     );
//   }
// }

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile_store/core/network/api_client.dart';
import 'package:mobile_store/features/home/screens/main_screen.dart';
import 'package:mobile_store/shared/token_storage.dart';
import 'core/constant/global_keys.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile_store/features/auth/screens/login_screen.dart';

// BẮT BUỘC THÊM DÒNG NÀY (Để Firebase biết cấu hình của dự án trên Windows/Web)
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Sửa: Thêm options vào đây
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('vi_VN', null);
  
  // Sửa: Thêm options vào đây để sửa lỗi [core/not-initialized] trên Windows
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Sửa: Chặn Push Notification nếu đang chạy ứng dụng dưới dạng phần mềm Windows
  if (!kIsWeb && !Platform.isWindows) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  String firstScreen = '/login';

  final accessToken = await TokenStorage.getAccessToken();
  final refreshToken = await TokenStorage.getRefreshToken();

  if (accessToken != null && accessToken.isNotEmpty) {
    try {
      bool isExpired = JwtDecoder.isExpired(accessToken);

      if (!isExpired) {
        debugPrint("✅ Access Token còn hạn, vào Home.");
        firstScreen = '/home';
      } else {
        debugPrint(
          "⚠️ Access Token đã hết hạn. Đang kiểm tra Refresh Token...",
        );

        if (refreshToken != null && refreshToken.isNotEmpty) {
          bool isRefreshSuccess = await ApiClient.refreshToken();

          if (isRefreshSuccess) {
            firstScreen = '/home';
          } else {
            debugPrint("❌ Refresh Token thất bại. Xóa dữ liệu và về Login.");
            await TokenStorage.clearTokens();
            firstScreen = '/login';
          }
        } else {
          await TokenStorage.clearTokens();
          firstScreen = '/login';
        }
      }
    } catch (e) {
      debugPrint("❌ Lỗi định dạng Token: $e");
      await TokenStorage.clearTokens();
      firstScreen = '/login';
    }
  }

  runApp(StoreAdminApp(initialRoute: firstScreen));
}

class StoreAdminApp extends StatelessWidget {
  final String initialRoute;

  const StoreAdminApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Beauty Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.pink, fontFamily: 'Roboto'),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainScreen(),
      },
    );
  }
}