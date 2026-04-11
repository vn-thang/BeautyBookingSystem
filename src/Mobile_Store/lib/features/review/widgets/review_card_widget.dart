import 'package:flutter/material.dart';
import '../models/store_review_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';

class ReviewCardWidget extends StatelessWidget {
  final StoreReviewModel review;
  final VoidCallback onReplyTap;

  const ReviewCardWidget({super.key, required this.review, required this.onReplyTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusSmall)),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.surface,
                  backgroundImage: review.customerAvatar != null ? NetworkImage(review.customerAvatar!) : null,
                  child: review.customerAvatar == null ? const Icon(Icons.person, color: AppColors.textSub) : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.customerName ?? 'Khách hàng', 
                        style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 15)
                      ),
                      Row(
                        children: List.generate(5, (index) => Icon(
                          index < review.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber, size: 16,
                        )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            
            Text(review.comment ?? 'Không có nhận xét', style: AppTextStyles.bodyText),
            const SizedBox(height: AppSpacing.lg),
            
            if (review.reply != null && review.reply!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimens.paddingSmall),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppDimens.radiusSmall)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Phản hồi của bạn:", style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(review.reply!, style: AppTextStyles.bodyText),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onReplyTap,
                  icon: const Icon(Icons.edit, size: 16, color: AppColors.primary),
                  label: Text("Sửa phản hồi", style: AppTextStyles.bodyText.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              )
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onReplyTap,
                  icon: const Icon(Icons.reply, color: AppColors.primary),
                  label: Text("Trả lời khách hàng", style: AppTextStyles.bodyText.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusSmall)),
                    side: const BorderSide(color: AppColors.primary), 
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}