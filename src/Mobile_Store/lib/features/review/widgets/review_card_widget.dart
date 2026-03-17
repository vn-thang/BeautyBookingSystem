import 'package:flutter/material.dart';
import '../models/store_review_model.dart';
import '../../../core/theme/app_colors.dart';

class ReviewCardWidget extends StatelessWidget {
  final StoreReviewModel review;
  final VoidCallback onReplyTap;

  const ReviewCardWidget({super.key, required this.review, required this.onReplyTap});

  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: review.customerAvatar != null ? NetworkImage(review.customerAvatar!) : null,
                  child: review.customerAvatar == null ? const Icon(Icons.person, color: Colors.grey) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.customerName ?? 'Khách hàng', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
            const SizedBox(height: 12),
            
            Text(review.comment ?? 'Không có nhận xét', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            
            if (review.reply != null && review.reply!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Phản hồi của bạn:", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(review.reply!, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onReplyTap,
                  icon: Icon(Icons.edit, size: 16, color: AppColors.primary),
                  label: Text("Sửa phản hồi", style: TextStyle(color: AppColors.primary)),
                ),
              )
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onReplyTap,
                  icon: Icon(Icons.reply, color: AppColors.primary),
                  label: Text("Trả lời khách hàng", style: TextStyle(color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary), 
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