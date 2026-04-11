import 'package:flutter/material.dart';
import 'package:mobile_store/core/theme/app_text_styles.dart';

class StatItemWidget extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const StatItemWidget({
  super.key,
  required this.icon,
  required this.iconColor,
  required this.value,
  required this.label,
});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 40, color: iconColor),
        const SizedBox(height: 8),
       Text(
  value,
  style: AppTextStyles.bodyText.copyWith(
    fontWeight: FontWeight.bold,
    fontSize: 18,
  ),
),
        const SizedBox(height: 4),
     Text(
  label,
  style: AppTextStyles.labelSmall,
),
      ],
    );
  }
}
