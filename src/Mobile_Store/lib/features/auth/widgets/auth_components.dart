import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';

class AuthGlassBackground extends StatelessWidget {
  final Widget child;

  const AuthGlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6FD8), Color(0xFFFF9A8B), Color(0xFF5EFCE8)],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingLarge, vertical: AppDimens.paddingMedium),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusLarge * 1.5), // Bo góc mượt mà hơn
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(AppDimens.paddingLarge),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.15), 
                    borderRadius: BorderRadius.circular(AppDimens.radiusLarge * 1.5),
                    border: Border.all(color: AppColors.white.withValues(alpha: 0.3), width: 1.5),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}