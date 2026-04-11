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
  final VoidCallback onConfirmPressed; 
  final VoidCallback onCompletePressed;
  final VoidCallback onNoShowPressed; 

  const BookingDetailBottomActions({
    super.key,
    required this.detail,
    required this.onCancelPressed,
    required this.onAssignStaffPressed,
    required this.onConfirmPressed, 
    required this.onCompletePressed,
    required this.onNoShowPressed, 
  });

  @override
  Widget build(BuildContext context) {
    bool needsStaffAssignment = detail.services.any((s) => s.staffId == null);

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
                  text: needsStaffAssignment ? 'DUYỆT & GÁN NV' : 'XÁC NHẬN ĐƠN',
                  onPressed: needsStaffAssignment ? onAssignStaffPressed : onConfirmPressed,
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
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppOutlineButton(
                      text: 'HỦY LỊCH',
                      color: AppColors.error,
                      onTap: onCancelPressed,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppOutlineButton(
                      text: 'VẮNG MẶT',
                      color: Colors.orange.shade700, 
                      onTap: onNoShowPressed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  text: 'HOÀN THÀNH DỊCH VỤ',
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