import 'package:flutter/material.dart';
import 'package:mobile_store/shared/widgets/buttons/app_buttons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';

import '../models/store_booking_model.dart';
class CompleteAndPayDialog extends StatelessWidget {
  final StoreBookingDetailModel detail;
  final VoidCallback onConfirm;

  const CompleteAndPayDialog({super.key, required this.detail, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
      title: Text('Xác nhận hoàn thành', style: AppTextStyles.heading1.copyWith(fontSize: 20, color: AppColors.success)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Khách hàng đã sử dụng xong dịch vụ này?', style: AppTextStyles.bodyText),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1), 
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall), 
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.5))
            ),
            child: Row(
              children: [
                const Icon(Icons.payments_outlined, color: AppColors.warning),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Số tiền cần thu: ${Formatters.formatCurrency(detail.remainingAmount)}',
                    style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Lưu ý: Xác nhận hoàn thành sẽ đồng thời ghi nhận bạn đã thu đủ số tiền trên (tiền mặt).', style: AppTextStyles.labelSmall.copyWith(fontStyle: FontStyle.italic)),
        ],
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: AppOutlineButton(
                text: 'HỦY', 
                color: AppColors.textSub,
                onTap: () => Navigator.pop(context)
              )
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppPrimaryButton(
                text: 'HOÀN TẤT',
                color: AppColors.success, 
                onPressed: () {
                  Navigator.pop(context); 
                  onConfirm(); 
                },
              )
            ),
          ],
        )
      ],
    );
  }
}

class CancelBookingDialog extends StatefulWidget {
  final Function(String) onConfirmCancel;

  const CancelBookingDialog({super.key, required this.onConfirmCancel});

  @override
  State<CancelBookingDialog> createState() => _CancelBookingDialogState();
}

class _CancelBookingDialogState extends State<CancelBookingDialog> {
  final TextEditingController _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
      title: Text('Lý do hủy đơn', style: AppTextStyles.heading1.copyWith(fontSize: 20, color: AppColors.error)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vui lòng nhập lý do từ chối/hủy đơn này để thông báo cho khách hàng:', style: AppTextStyles.bodyText),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _reasonController,
              maxLines: 3,
              autofocus: true, 
              style: AppTextStyles.bodyText,
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.white,
                hintText: 'VD: Cửa hàng mất điện đột xuất, Không sắp xếp được thợ...',
                hintStyle: AppTextStyles.labelSmall,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  borderSide: BorderSide(color: AppColors.surface, width: 1.5)
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall), 
                  borderSide: const BorderSide(color: AppColors.error, width: 1.5)
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall), 
                  borderSide: const BorderSide(color: AppColors.error)
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall), 
                  borderSide: const BorderSide(color: AppColors.error, width: 2)
                ),
                contentPadding: const EdgeInsets.all(AppSpacing.md),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Vui lòng không để trống lý do';
                if (value.trim().length < 5) return 'Lý do quá ngắn';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: AppOutlineButton(
                text: 'ĐÓNG', 
                color: AppColors.textSub,
                onTap: () => Navigator.pop(context)
              )
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppPrimaryButton(
                text: 'XÁC NHẬN',
                color: AppColors.error, 
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context); 
                    widget.onConfirmCancel(_reasonController.text.trim());
                  }
                },
              )
            ),
          ],
        )
      ],
    );
  }
}