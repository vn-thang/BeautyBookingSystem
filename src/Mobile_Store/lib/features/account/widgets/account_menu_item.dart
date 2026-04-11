import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AccountMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const AccountMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? AppColors.textMain;
    
    return ListTile(
      leading: Icon(icon, color: itemColor),
      title: Text(
        title, 
        style: AppTextStyles.bodyText.copyWith(color: itemColor, fontWeight: FontWeight.w600)
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSub),
      onTap: onTap,
    );
  }
}