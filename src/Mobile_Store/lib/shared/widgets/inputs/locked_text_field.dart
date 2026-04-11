import 'package:flutter/material.dart';
import 'package:mobile_store/core/theme/app_dimens.dart';
import 'package:mobile_store/core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';

class LockedTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final IconData icon;

  const LockedTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: AppTextStyles.bodyText.copyWith(
            color: AppColors.textSub, 
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          enabled: false, 
          style: AppTextStyles.bodyText.copyWith(
            color: AppColors.textSub,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface, 
            prefixIcon: Icon(icon, size: 22, color: AppColors.textSub.withValues(alpha: 0.6)),
            suffixIcon: Icon(Icons.lock_outline, size: 18, color: AppColors.textSub.withValues(alpha: 0.5)),
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              borderSide: BorderSide.none,
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
              borderSide: BorderSide(color: AppColors.textSub.withValues(alpha: 0.1), width: 1), 
            ),
          ),
        ),
      ],
    );
  }
}