import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';

class CustomerSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const CustomerSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingMedium, 
        vertical: AppDimens.paddingSmall,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.bodyText,
        cursorColor: AppColors.primary, 
        decoration: InputDecoration(
          hintText: 'Tìm theo tên, số điện thoại...',
          hintStyle: AppTextStyles.labelSmall,
          prefixIcon: const Icon(Icons.search, color: AppColors.textSub),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSub),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: AppColors.textSub.withValues(alpha: 0.05),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50), 
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5), width: 1),
          ),
        ),
      ),
    );
  }
}