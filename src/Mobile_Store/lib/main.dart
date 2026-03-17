import 'package:flutter/material.dart';
// 1. IMPORT THƯ VIỆN FIREBASE
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile_store/core/network/api_client.dart';
import 'package:mobile_store/features/home/screens/main_screen.dart';
import 'package:mobile_store/shared/token_storage.dart';
import 'firebase_options.dart'; 
import 'core/constant/global_keys.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mobile_store/features/auth/screens/login_screen.dart';


// 2. HÀM XỬ LÝ THÔNG BÁO KHI APP CHẠY NGẦM (BACKGROUND) / ĐÃ TẮT
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("📬 [Background] Nhận thông báo: ${message.notification?.title}");
}

Future<void> main() async {
  // Bắt buộc phải gọi dòng này trước tiên
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting('vi_VN', null); 

  // 3. KHỞI TẠO FIREBASE
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 4. ĐĂNG KÝ LẮNG NGHE THÔNG BÁO BACKGROUND
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  String firstScreen = '/login'; // Mặc định là vào màn hình đăng nhập

  // Lấy cả 2 token từ storage lên
  final accessToken = await TokenStorage.getAccessToken();
  final refreshToken = await TokenStorage.getRefreshToken(); // Bạn nhớ thêm hàm này vào TokenStorage nhé

  if (accessToken != null && accessToken.isNotEmpty) {
    try {
      // Giải mã xem Access Token đã hết hạn chưa (hết 15 phút chưa)
      bool isExpired = JwtDecoder.isExpired(accessToken);

      if (!isExpired) {
        // TRƯỜNG HỢP 1: Token CÒN HẠN -> Lướt thẳng vào màn hình chính!
        debugPrint("✅ Access Token còn hạn, vào Home.");
        firstScreen = '/home'; 
      } else {
        // TRƯỜNG HỢP 2: Token ĐÃ HẾT HẠN -> Dùng Refresh Token để cứu vãn
        debugPrint("⚠️ Access Token đã hết hạn. Đang kiểm tra Refresh Token...");

        if (refreshToken != null && refreshToken.isNotEmpty) {
          bool isRefreshSuccess = await ApiClient.refreshToken();
          
          if (isRefreshSuccess) {
            firstScreen = '/home';
          } else {
            // Cứu thất bại (Refresh Token cũng tẻo hoặc lỗi mạng) -> Xóa sạch & Bắt đăng nhập lại
            debugPrint("❌ Refresh Token thất bại. Xóa dữ liệu và về Login.");
            await TokenStorage.clearTokens(); 
            firstScreen = '/login';
          }
        } else {
          // Không có Refresh Token trong máy -> Đăng nhập lại
          await TokenStorage.clearTokens();
          firstScreen = '/login';
        }
      }
    } catch (e) {
      // Bắt lỗi nếu Access Token bị móp méo, sai định dạng (không parse được)
      debugPrint("❌ Lỗi định dạng Token: $e");
      await TokenStorage.clearTokens();
      firstScreen = '/login';
    }
  }

  // 6. Khởi chạy App và truyền cái route đầu tiên vào
  runApp(StoreAdminApp(initialRoute: firstScreen));
}

class StoreAdminApp extends StatelessWidget {
  final String initialRoute; // Biến hứng giá trị từ hàm main

  // Constructor
  const StoreAdminApp({super.key, required this.initialRoute}); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Beauty Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink, // Note: Ở phiên bản Flutter mới, bạn có thể cân nhắc dùng colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink)
        fontFamily: 'Roboto', 
      ),
      
      // THAY THẾ thuộc tính `home` bằng `initialRoute` và `routes`
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginScreen(),
        // Nhớ đổi tên `HomeScreen` cho đúng với class màn hình chính của bạn nhé
        '/home': (context) => const MainScreen(), 
      },
    );
  }
}