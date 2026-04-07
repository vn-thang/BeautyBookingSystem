import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 44, 
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: color,
            elevation: 2,
            shadowColor: AppColors.textMain.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingSmall),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            ),
          ),
          icon: Icon(icon, size: 20),
          label: Text(
            text, 
            style: AppTextStyles.bodyText.copyWith(
              color: color, 
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}