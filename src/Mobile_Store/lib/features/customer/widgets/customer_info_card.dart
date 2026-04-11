import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/customer_profile_model.dart';

class CustomerInfoCard extends StatelessWidget {
  final CustomerProfileModel profile;

  const CustomerInfoCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSub.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: AppTextStyles.heading1.copyWith(fontSize: 20),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: AppColors.textSub),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      profile.phone,
                      style: AppTextStyles.bodyText.copyWith(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 36,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      backgroundImage: (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty)
          ? NetworkImage(profile.avatarUrl!)
          : null,
      child: (profile.avatarUrl == null || profile.avatarUrl!.isEmpty)
          ? Text(
              profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?',
              style: AppTextStyles.heading1.copyWith(
                fontSize: 28, 
                color: AppColors.primary,
              ),
            )
          : null,
    );
  }
}