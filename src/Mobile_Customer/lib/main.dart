// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'core/service/push_notification_service.dart';
// import 'injection/service_locator.dart' as di;
// import 'core/router/app_router.dart';
// import 'features/auth/presentation/bloc/auth_bloc.dart';
// import 'features/auth/presentation/bloc/auth_event.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   await PushNotificationService.init();
//   await di.init();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (_) => di.sl<AuthBloc>()..add(CheckAuthEvent())),
//       ],
//       child: MaterialApp.router(
//         debugShowCheckedModeBanner: false,
//         routerConfig: AppRouter.router,
//       ),
//     );
//   }
// }

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io' show Platform; // Import để check nền tảng Windows/Android
import 'package:flutter/foundation.dart' show kIsWeb; // Import để check Web

import 'core/service/push_notification_service.dart';
import 'injection/service_locator.dart' as di;
import 'core/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

// BẮT BUỘC IMPORT FILE NÀY (Do FlutterFire CLI sinh ra)
import 'firebase_options.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Khởi tạo Firebase kèm Options cho từng nền tảng
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );

  // 2. Chặn Push Notification nếu đang chạy trên Windows để tránh Crash
  if (!kIsWeb && !Platform.isWindows) {
    await PushNotificationService.init();
  }

  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()..add(CheckAuthEvent())),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}