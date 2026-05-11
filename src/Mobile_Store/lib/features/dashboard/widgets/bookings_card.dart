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
        label: label, // Không dùng \n nữa
        count: count.toString(), // 🎯 Truyền riêng số lượng vào trường count
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
            // CỤM TIÊU ĐỀ: Bấm được toàn dải
           InkWell(
  onTap: onViewAllBookings,
  borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0), // Tăng padding dọc lên 12 cho dễ bấm
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              const Icon(Icons.list_alt, color: AppColors.warning, size: 24), 
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Đơn đặt lịch', 
                  style: AppTextStyles.bodyText.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        // 🎯 CHỈ ĐỂ LẠI ICON MŨI TÊN
       const Icon(Icons.keyboard_double_arrow_right, color: AppColors.textSub, size: 24),
      ],
    ),
  ),
),
            const SizedBox(height: AppSpacing.xl),
            
            // CỤM 4 TAB: Có khoảng cách (SizedBox) ở giữa
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Expanded(child: _buildBookingTab(context, icon: Icons.pending_actions, label: 'Chờ duyệt', count: counts.pending, index: 1)),
                const SizedBox(width: 4),
                Expanded(child: _buildBookingTab(context, icon: Icons.check_circle_outline, label: 'Đã xác nhận', count: counts.confirmed, index: 2)),
                const SizedBox(width: 4),
                Expanded(child: _buildBookingTab(context, icon: Icons.check_box_outlined, label: 'Hoàn thành', count: counts.completed, index: 3)),
                const SizedBox(width: 4),
                Expanded(child: _buildBookingTab(context, icon: Icons.cancel_presentation, label: 'Khách hủy', count: counts.cancelledByCustomer, index: 4)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}