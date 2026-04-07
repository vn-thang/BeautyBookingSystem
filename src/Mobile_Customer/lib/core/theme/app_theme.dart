import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: const Color(0xFFFF5C8A),
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF5C8A)),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0x00FFFFFF),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
  );
}