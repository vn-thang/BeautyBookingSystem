import 'package:flutter/material.dart';
// Đảm bảo file màn hình nằm đúng đường dẫn này
import 'features/dashboard/store_dashboard_screen.dart';

void main() {
  runApp(const StoreAdminApp());
}

class StoreAdminApp extends StatelessWidget {
  // Đã triệt tiêu cảnh báo vàng bằng cú pháp super.key
  const StoreAdminApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Store Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        fontFamily: 'Roboto', 
      ),
      home: const StoreDashboardScreen(), // Khởi chạy màn hình Dashboard
    );
  }
}
