import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const pageTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 14.5,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const bodyMuted = TextStyle(
    fontSize: 13.5,
    height: 1.45,
    color: AppColors.textSecondary,
    fontWeight: FontWeight.w500,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static const chip = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static const error = TextStyle(
    color: Colors.red,
    fontWeight: FontWeight.w600,
  );
}
