import 'package:flutter/material.dart';
import 'package:mobile_store/features/booking/screens/booking_detail_screen.dart';
import 'package:mobile_store/shared/widgets/buttons/app_buttons.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/wallet_transaction_model.dart';

class TransactionReceiptSheet extends StatelessWidget {
  final WalletTransactionModel transaction;

  const TransactionReceiptSheet({super.key, required this.transaction});

  static void show(BuildContext context, WalletTransactionModel tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLarge)),
      ),
      builder: (_) => TransactionReceiptSheet(transaction: tx),
    );
  }

  Map<String, String?> _extractDescriptionAndImage(String fullText) {
    final RegExp urlRegExp = RegExp(r'(https?:\/\/.*\.(?:png|jpg|jpeg|webp))', caseSensitive: false);
    final match = urlRegExp.firstMatch(fullText);

    if (match != null) {
      String imageUrl = match.group(0)!;
      String cleanDescription = fullText.replaceAll(RegExp(r'\[Biên lai:.*?\]'), '').trim();
      return {'description': cleanDescription, 'imageUrl': imageUrl};
    }
    return {'description': fullText, 'imageUrl': null};
  }

  @override
  Widget build(BuildContext context) {
    final isAdd = transaction.isAddition;
    final sign = isAdd ? '+' : '-';
    
    final String normStatus = transaction.status.toLowerCase();
    final bool isPending = normStatus == 'pending' || normStatus == '0';
    final bool isFailed = normStatus == 'failed' || normStatus == 'cancelled' || normStatus == 'rejected' || normStatus == '2' || normStatus == '3';
    
    final extractedData = _extractDescriptionAndImage(transaction.description);
    final String cleanDescription = extractedData['description']!;
    final String? finalImageUrl = (transaction.receiptImageUrl?.isNotEmpty == true) 
        ? transaction.receiptImageUrl 
        : extractedData['imageUrl'];

    final statusColor = isPending ? AppColors.warning : (isFailed ? AppColors.error : AppColors.success);
    final statusIcon = isPending ? Icons.access_time_filled : (isFailed ? Icons.cancel : Icons.check_circle);
    final titleText = isPending ? 'Đang chờ duyệt' : (isFailed ? 'Giao dịch thất bại' : 'Giao dịch thành công');
    final statusRowText = isPending ? 'Đang chờ xử lý' : (isFailed ? 'Thất bại' : 'Thành công');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: AppSpacing.xl),

            CircleAvatar(
              radius: 30,
              backgroundColor: statusColor.withValues(alpha: 0.1),
              child: Icon(statusIcon, color: statusColor, size: 40),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            Text(titleText, style: AppTextStyles.heading1.copyWith(fontSize: 18)),
            const SizedBox(height: AppSpacing.sm),
            
            Text(
              '$sign${Formatters.formatCurrency(transaction.amount.abs())}',
              style: AppTextStyles.heading1.copyWith(fontSize: 28, color: statusColor),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg), 
              child: Divider(color: AppColors.surface)
            ),

            _buildReceiptRow('Trạng thái', statusRowText, valueColor: statusColor),
            if (transaction.createdAt != null)
              _buildReceiptRow('Thời gian', '${transaction.createdAt!.hour.toString().padLeft(2, '0')}:${transaction.createdAt!.minute.toString().padLeft(2, '0')} - ${transaction.createdAt!.day}/${transaction.createdAt!.month}/${transaction.createdAt!.year}'),
            _buildReceiptRow('Mã giao dịch', '#${transaction.id}'),
            _buildReceiptRow('Nội dung', cleanDescription),

            const SizedBox(height: AppSpacing.lg),

            if (isFailed && transaction.adminNote?.isNotEmpty == true)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimens.paddingSmall),
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.05),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Text('Lý do từ chối', style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, color: AppColors.error)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(transaction.adminNote!, style: AppTextStyles.labelSmall.copyWith(color: AppColors.error)),
                  ],
                ),
              ),

            if (finalImageUrl != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Biên lai', style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, color: AppColors.textSub)),
                  const SizedBox(height: AppSpacing.sm),
                  GestureDetector(
                    onTap: () => _showFullScreenImage(context, finalImageUrl),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                      child: Image.network(
                        finalImageUrl,
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(child: Text('Không thể tải ảnh bill', style: AppTextStyles.labelSmall.copyWith(color: AppColors.error))),
                        loadingBuilder: (_, child, progress) => progress == null ? child : const SizedBox(height: 100, child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),

            if (transaction.bookingId != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppPrimaryButton(
                text: 'Xem chi tiết đơn hàng',
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BookingDetailScreen(bookingId: transaction.bookingId!)),
                  );
                },
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub)),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w600, color: valueColor ?? AppColors.textMain),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black87,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}