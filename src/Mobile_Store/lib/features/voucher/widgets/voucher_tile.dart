import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart'; // Sử dụng hàm format tiền tệ chung
import '../models/voucher_model.dart';

class VoucherTile extends StatelessWidget {
  final VoucherModel voucher;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const VoucherTile({super.key, required this.voucher, required this.onEdit, required this.onDelete});

  Color _getStatusColor() {
    switch (voucher.status) {
      case 'Đang diễn ra': return AppColors.success;
      case 'Sắp diễn ra': return AppColors.warning;
      default: return AppColors.textSub;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    
    final discountText = voucher.discountType == 0 
        ? Formatters.formatCurrency(voucher.discountValue)
        : '${voucher.discountValue.toStringAsFixed(0)}%';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
      elevation: 2,
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1), 
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall)
                  ),
                  child: Text(
                    voucher.code, 
                    style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, color: AppColors.error, fontSize: 16)
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1), 
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall)
                  ),
                  child: Text(
                    voucher.status, 
                    style: AppTextStyles.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.bold)
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Giảm $discountText (Tối đa ${Formatters.formatCurrency(voucher.maxDiscount)})', 
              style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w600, fontSize: 15)
            ),
            const SizedBox(height: 4),
            Text(
              'Đơn tối thiểu: ${Formatters.formatCurrency(voucher.minOrderValue)}', 
              style: AppTextStyles.labelSmall
            ),
            const SizedBox(height: 4),
            Text(
              'HSD: ${Formatters.formatDateTime(voucher.endDate)}', // Dùng hàm format ngày
              style: AppTextStyles.labelSmall
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đã dùng: ${voucher.usedCount} / ${voucher.usageLimit}', 
                  style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w500)
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF0068FF), size: 20), // Xanh dương
                      onPressed: onEdit, 
                      constraints: const BoxConstraints()
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error, size: 20), 
                      onPressed: onDelete, 
                      constraints: const BoxConstraints()
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}