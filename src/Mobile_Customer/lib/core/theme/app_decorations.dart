import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  static const pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.background,
      Color(0xFFFFEEF5),
      AppColors.surface,
    ],
  );

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.placeholderStart,
      AppColors.placeholderEnd,
    ],
  );

  static const cardShadow = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
  ];

  static const softShadow = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];

  static const topBarShadow = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 14,
      offset: Offset(0, 6),
    ),
  ];

  static const avatarShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
}
