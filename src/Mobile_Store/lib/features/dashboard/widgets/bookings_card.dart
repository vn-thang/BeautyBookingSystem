import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/circle_action_button.dart';
import '../../booking/screens/booking_management_screen.dart';
import '../models/store_dashboard_model.dart';

class BookingsCard extends StatelessWidget {
  final BookingCountsModel counts;
  final VoidCallback onViewAllBookings; 
  
  const BookingsCard({
    super.key, 
    required this.counts,
    required this.onViewAllBookings,
  });

  Widget _buildBookingTab(BuildContext context, {required IconData icon, required String label, required int count, required int index}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BookingManagementScreen(initialIndex: index)),
        );
      },
      child: CircleActionButton(
        icon: icon, 
        label: '$label\n($count)', 
        bgColor: AppColors.primary.withValues(alpha: 0.1), 
        iconColor: AppColors.primary
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusSmall)),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        child: Column(
          children: [
            InkWell(
              onTap: onViewAllBookings,
              borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.list_alt, color: AppColors.warning, size: 24), 
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Đơn đặt lịch', 
                          style: AppTextStyles.bodyText.copyWith(fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                    Text(
                      'Xem tất cả >', 
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500)
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBookingTab(context, icon: Icons.pending_actions, label: 'Chờ duyệt', count: counts.pending, index: 1),
                _buildBookingTab(context, icon: Icons.check_circle_outline, label: 'Đã xác nhận', count: counts.confirmed, index: 2),
                _buildBookingTab(context, icon: Icons.check_box_outlined, label: 'Hoàn thành', count: counts.completed, index: 3),
                _buildBookingTab(context, icon: Icons.cancel_presentation, label: 'Khách hủy', count: counts.cancelledByCustomer, index: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}