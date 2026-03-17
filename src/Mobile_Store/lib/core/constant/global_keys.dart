import 'package:flutter/material.dart';

// Biến toàn cục này dùng để điều hướng màn hình từ các file không có BuildContext (như api_client)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();