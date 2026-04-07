import 'package:flutter/material.dart';
import 'package:mobile_store/shared/widgets/buttons/app_buttons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/store_booking_model.dart';

class BookingDetailBottomActions extends StatelessWidget {
  final StoreBookingDetailModel detail;
  final VoidCallback onCancelPressed;
  final VoidCallback onAssignStaffPressed;
  final VoidCallback onCompletePressed;

  const BookingDetailBottomActions({
    super.key,
    required this.detail,
    required this.onCancelPressed,
    required this.onAssignStaffPressed,
    required this.onCompletePressed,
  });

  @override
  Widget build(BuildContext context) {
    if (detail.status.toLowerCase() == 'pending') {
      return Container(
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white, 
          boxShadow: [BoxShadow(color: AppColors.textMain.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: AppOutlineButton(
                  text: 'TỪ CHỐI',
                  color: AppColors.error,
                  onTap: onCancelPressed,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: AppPrimaryButton(
                  text: 'DUYỆT & GÁN NV',
                  onPressed: onAssignStaffPressed,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (detail.status.toLowerCase() == 'confirmed') {
      return Container(
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.white, 
          boxShadow: [BoxShadow(color: AppColors.textMain.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: AppOutlineButton(
                  text: 'HỦY ĐƠN',
                  color: AppColors.error,
                  onTap: onCancelPressed,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: AppPrimaryButton(
                  text: 'HOÀN THÀNH',
                  color: AppColors.success, 
                  onPressed: onCompletePressed,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}