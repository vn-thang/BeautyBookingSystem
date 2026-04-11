import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';

import '../../../shared/models/service_group_model.dart';
import '../../../shared/models/service_model.dart';

class Step1ServicesWidget extends StatelessWidget {
  final List<ServiceGroupModel> serviceGroups;
  final List<ServiceModel> selectedServices;
  final Function(ServiceModel, bool) onServiceToggled;

  const Step1ServicesWidget({
    super.key,
    required this.serviceGroups,
    required this.selectedServices,
    required this.onServiceToggled,
  });

  @override
  Widget build(BuildContext context) {
    if (serviceGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.spa_outlined, size: 64, color: AppColors.textSub.withValues(alpha: 0.3)),
            const SizedBox(height: AppSpacing.md),
            Text(
              "Chưa có dịch vụ nào khả dụng.",
              style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      itemCount: serviceGroups.length,
      itemBuilder: (context, groupIndex) {
        final group = serviceGroups[groupIndex];
        if (group.services.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    group.name.toUpperCase(), 
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 16, 
                      color: AppColors.textMain,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            ...group.services.map((service) {
              final isSelected = selectedServices.any((s) => s.id == service.id);

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildServiceCard(service, isSelected),
              );
            }),
            
            if (groupIndex < serviceGroups.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Divider(color: AppColors.surface.withValues(alpha: 0.5), height: 1),
              ),
          ],
        );
      },
    );
  }

  Widget _buildServiceCard(ServiceModel service, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.surface,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: isSelected
            ? [] 
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          onTap: () => onServiceToggled(service, !isSelected),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingMedium),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: isSelected ? AppColors.primary : AppColors.textSub,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: AppTextStyles.bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primary : AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.sell_outlined, size: 14, color: AppColors.textSub),
                          const SizedBox(width: 4),
                          Text(
                            Formatters.formatCurrency(service.price),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary, 
                              fontWeight: FontWeight.w600
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Icon(Icons.schedule, size: 14, color: AppColors.textSub),
                          const SizedBox(width: 4),
                          Text(
                            '${service.durationMinutes} phút',
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSub),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(left: AppSpacing.sm),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.textSub.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: AppColors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}