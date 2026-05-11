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
  String getInitials(String name) {
  if (name.isEmpty) return '?';

  final parts = name.trim().split(' ');
  if (parts.length == 1) return parts[0][0].toUpperCase();

  return (parts.first[0] + parts.last[0]).toUpperCase();
}

  const BookingCard({super.key, required this.booking, required this.onTap});

  (String, Color) _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ('Chờ duyệt', AppColors.warning);
      case 'depositpaid':
        return ('Đã cọc', const Color(0xFF00897B));
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
            CircleAvatar(
  radius: 30, 
  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
  backgroundImage: (booking.avatarUrl != null && booking.avatarUrl!.isNotEmpty)
      ? NetworkImage(booking.avatarUrl!)
      : null,
  child: (booking.avatarUrl == null || booking.avatarUrl!.isEmpty)
      ? Text(
          getInitials(booking.customerName),
          style: AppTextStyles.bodyText.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        )
      : null,
),
            const SizedBox(width: AppSpacing.md),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.customerName, 
                    style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          Formatters.formatCurrency(booking.finalPrice),
                          style: AppTextStyles.bodyText.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusInfo.$2.withValues(alpha: 0.1), 
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusInfo.$1, 
                          style: AppTextStyles.labelSmall.copyWith(color: statusInfo.$2, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: AppColors.textSub),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded( 
                        child: Text(
                          Formatters.formatDateTime(booking.createdAt), 
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSub),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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