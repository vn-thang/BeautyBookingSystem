import 'package:flutter/material.dart';
import 'package:mobile_store/core/theme/app_dimens.dart';
import '../../../core/theme/app_colors.dart';

class SnackBarHelper {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
     shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showError(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lỗi: ${error.replaceAll('Exception: ', '')}'),
        backgroundColor: AppColors.error, 
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}