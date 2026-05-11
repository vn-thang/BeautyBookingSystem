import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart'; 
import '../models/top_performance_item_model.dart';

class TopPerformanceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Future<List<TopPerformanceItemModel>> future;
  final void Function(TopPerformanceItemModel item)? onItemTap;

  const TopPerformanceCard({
    super.key,
    required this.title,
    required this.icon,
    required this.future,
    this.onItemTap, 
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
      margin: const EdgeInsets.only(bottom: AppDimens.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title, 
                    style: AppTextStyles.bodyText.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: AppColors.surface),
            
            FutureBuilder<List<TopPerformanceItemModel>>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppDimens.paddingMedium), 
                      child: CircularProgressIndicator(color: AppColors.primary), 
                    )
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}', style: AppTextStyles.bodyText.copyWith(color: AppColors.error)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.paddingMedium), 
                      child: Text('Chưa có dữ liệu', style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub))
                    )
                  );
                }

                final items = snapshot.data!;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), 
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const Divider(height: 16, color: AppColors.surface), 
                  itemBuilder: (context, index) {
                    final item = items[index];
                    
                    return InkWell(
                      onTap: () {
                        if (onItemTap != null) {
                          onItemTap!(item); 
                        }
                      },
                      borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs), 
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center, 
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: index < 3 ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surface,
                              child: Text('${index + 1}', style: AppTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: index < 3 ? AppColors.primary : AppColors.textSub
                              )),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name, 
                                    style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w500), 
                                    maxLines: 1, 
                                    overflow: TextOverflow.ellipsis
                                  ),
                                  const SizedBox(height: 4),
                                  
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        flex: 1,
                                        child: Text(
                                          '${item.count} lượt', 
                                          style: AppTextStyles.labelSmall,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8), 
                                      Flexible(
                                        flex: 2,
                                        child: Text(
                                          Formatters.formatCurrency(item.revenue),
                                          style: AppTextStyles.bodyText.copyWith(
                                            fontWeight: FontWeight.w600, 
                                            color: AppColors.success, 
                                            fontSize: 14
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            if (onItemTap != null) 
                              const Padding(
                                padding: EdgeInsets.only(left: AppSpacing.sm),
                                child: Icon(Icons.chevron_right, size: 16, color: AppColors.textSub),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}