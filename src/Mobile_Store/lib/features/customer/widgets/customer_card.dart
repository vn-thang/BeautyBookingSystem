import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart'; // Sử dụng Formatters chung
import '../models/customer_list_model.dart';

class CustomerCard extends StatelessWidget {
  final CustomerListModel customer;
  final VoidCallback onTap;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusSmall)),
      color: AppColors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.paddingSmall),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.fullName,
                      style: AppTextStyles.bodyText.copyWith(
                        fontWeight: FontWeight.bold, 
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 14, color: AppColors.textSub),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          customer.phone, 
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSub),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Đã đến: ${customer.totalVisits} lần', 
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.success, 
                            fontWeight: FontWeight.w500, 
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(customer.totalSpent), 
                          style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.error, 
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.chevron_right, color: AppColors.textSub),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      backgroundImage: (customer.avatarUrl != null && customer.avatarUrl!.isNotEmpty)
          ? NetworkImage(customer.avatarUrl!)
          : null,
      child: (customer.avatarUrl == null || customer.avatarUrl!.isEmpty)
          ? Text(
              customer.fullName.isNotEmpty ? customer.fullName[0].toUpperCase() : '?',
              style: AppTextStyles.heading1.copyWith(
                fontSize: 20, 
                color: AppColors.primary,
              ),
            )
          : null,
    );
  }
}