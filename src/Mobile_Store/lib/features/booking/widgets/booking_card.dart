import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../models/store_booking_model.dart';

class BookingCard extends StatelessWidget {
  final StoreBookingListModel booking;
  final VoidCallback onTap;

  const BookingCard({super.key, required this.booking, required this.onTap});

  (String, Color) _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ('Chờ duyệt', AppColors.warning);
      case 'confirmed':
        return ('Đã duyệt', const Color(0xFF0068FF)); 
      case 'completed':
        return ('Hoàn thành', AppColors.success);
      case 'cancelled':
        return ('Đã hủy', AppColors.error);
      default:
        return ('Không rõ', AppColors.textSub);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo(booking.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(bottom: BorderSide(color: AppColors.surface)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              child: Container(
                width: 60,
                height: 60,
                color: AppColors.surface,
                child: const Icon(Icons.receipt_long, color: AppColors.textSub, size: 30),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          booking.customerName, 
                          style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '• ${statusInfo.$1}', 
                        style: AppTextStyles.labelSmall.copyWith(color: statusInfo.$2, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    Formatters.formatCurrency(booking.finalPrice),
                    style: AppTextStyles.bodyText.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: AppColors.textSub),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        Formatters.formatDateTime(booking.createdAt), 
                        style: AppTextStyles.labelSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}