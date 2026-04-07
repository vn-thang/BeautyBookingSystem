import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart'; // Áp dụng Formatters
import '../models/customer_profile_model.dart';

class CustomerStatsRow extends StatelessWidget {
  final CustomerProfileModel profile;

  const CustomerStatsRow({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatCard(
          title: 'Đã đến',
          value: '${profile.totalVisits}',
          unit: 'lần',
          icon: Icons.check_circle_outline,
          color: AppColors.success,
        ),
        const SizedBox(width: AppSpacing.md),
        _buildStatCard(
          title: 'Chi tiêu',
          value: Formatters.formatCurrency(profile.totalSpent), 
          unit: '',
          icon: Icons.monetization_on_outlined,
          color: AppColors.primary,
        ),
        const SizedBox(width: AppSpacing.md),
        _buildStatCard(
          title: 'Hủy lịch',
          value: '${profile.totalCancelled}',
          unit: 'lần',
          icon: Icons.cancel_outlined,
          color: profile.totalCancelled >= 3 ? AppColors.error : AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimens.paddingMedium, 
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title, 
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSub),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$value $unit'.trim(),
              style: AppTextStyles.bodyText.copyWith(
                fontWeight: FontWeight.bold, 
                color: color, 
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}