import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
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
        bgColor: Colors.pink[50]!, 
        iconColor: AppColors.primary
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            InkWell(
              onTap: onViewAllBookings,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.list_alt, color: Colors.orange, size: 24), SizedBox(width: 8),
                        Text('Đơn đặt lịch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text('Xem tất cả >', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
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