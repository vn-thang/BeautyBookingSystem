import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';

class MarketingMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const MarketingMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingMedium, 
          vertical: AppDimens.paddingMedium,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppColors.textMain), 
            const SizedBox(width: 16), 
            
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMain,
                ),
              ),
            ),
            
            const Icon(Icons.chevron_right, size: 24, color: AppColors.textSub),
          ],
        ),
      ),
    );
  }
}