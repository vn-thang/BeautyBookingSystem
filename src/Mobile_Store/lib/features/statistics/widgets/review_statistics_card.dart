import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/review_statistics_model.dart';

class ReviewStatisticsCard extends StatelessWidget {
  final Future<ReviewStatisticsModel> future;

  const ReviewStatisticsCard({super.key, required this.future});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.warning),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Đánh giá của khách',
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: AppDimens.paddingLarge, color: AppColors.surface), 
            
            FutureBuilder<ReviewStatisticsModel>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppDimens.paddingMedium),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Lỗi: ${snapshot.error}',
                      style: AppTextStyles.bodyText.copyWith(color: AppColors.error),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.totalReviews == 0) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimens.paddingMedium),
                      child: Text(
                        'Chưa có đánh giá nào',
                        style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub),
                      ),
                    ),
                  );
                }

                final data = snapshot.data!;
                return Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          data.averageRating.toStringAsFixed(1),
                          style: AppTextStyles.heading1.copyWith(fontSize: 40),
                        ),
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, color: AppColors.warning, size: 20),
                            Icon(Icons.star_rounded, color: AppColors.warning, size: 20),
                            Icon(Icons.star_rounded, color: AppColors.warning, size: 20),
                            Icon(Icons.star_rounded, color: AppColors.warning, size: 20),
                            Icon(Icons.star_half_rounded, color: AppColors.warning, size: 20),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${data.totalReviews} lượt đánh giá',
                          style: AppTextStyles.labelSmall,
                        ),
                      ],
                    ),
                    
                    const SizedBox(width: AppDimens.paddingLarge),
                    
                    Expanded(
                      child: Column(
                        children: [
                          _buildRatingBar('5', data.fiveStarCount, data.totalReviews),
                          _buildRatingBar('4', data.fourStarCount, data.totalReviews),
                          _buildRatingBar('3', data.threeStarCount, data.totalReviews),
                          _buildRatingBar('2', data.twoStarCount, data.totalReviews),
                          _buildRatingBar('1', data.oneStarCount, data.totalReviews),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(String starLabel, int count, int total) {
    final double percent = total > 0 ? (count / total) : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            starLabel,
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const Icon(Icons.star_rounded, color: AppColors.warning, size: 14),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 8,
                backgroundColor: AppColors.surface,
                color: AppColors.warning,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 30, 
            child: Text(
              '$count',
              style: AppTextStyles.labelSmall,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}