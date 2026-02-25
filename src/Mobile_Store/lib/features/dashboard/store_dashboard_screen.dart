import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'package:mobile_store/shared/widgets/stat_item_widget.dart';
import 'package:mobile_store/shared/widgets/circle_action_button.dart';
class StoreDashboardScreen extends StatelessWidget {
  // Đã sửa cảnh báo Key? key thành cú pháp mới
  const StoreDashboardScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildDetailedStatsCard(),
                  const SizedBox(height: 16),
                  _buildCommissionCard(),
                  const SizedBox(height: 16),
                  _buildBookingsCard(),
                  const SizedBox(height: 16),
                  _buildMenuOptionsCard(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 24),
      // Bỏ chữ 'const' ở đây để tránh lỗi invalid_constant
      decoration: BoxDecoration(
        color: AppColors.primary, 
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 50, height: 50, color: Colors.white24,
              child: const Icon(Icons.store, color: Colors.white, size: 30),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tiệm tóc Hari', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                // Đã thay .withOpacity(0.9) thành .withValues(alpha: 0.9) theo chuẩn Flutter mới
                Text('Địa chỉ: 12 Đông Viên, Thành phố Hà...', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications, color: Colors.white))
        ],
      ),
    );
  }

  Widget _buildDetailedStatsCard() {
    return Card(
      elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.bar_chart, color: Colors.blue, size: 24), SizedBox(width: 8),
                Text('Thống kê chi tiết', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              // Bỏ chữ 'const' ở mảng này
              children: [
                const StatItemWidget(icon: Icons.groups, iconColor: Colors.grey, value: '0', label: 'Khách hàng'),
                StatItemWidget(icon: Icons.calendar_month, iconColor: AppColors.primary, value: '0', label: 'Lịch đặt'),
                const StatItemWidget(icon: Icons.attach_money, iconColor: Colors.green, value: '0', label: 'Đồng'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommissionCard() {
    return Card(
      elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.pie_chart, color: Colors.orange, size: 24), SizedBox(width: 8),
                    Text('Thống kê tiền hoa hồng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                // Bỏ chữ 'const' ở Text này
                Text('Xem tất cả >', style: TextStyle(color: AppColors.primary, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatItemWidget(icon: Icons.monetization_on, iconColor: Colors.yellow[700]!, value: '0', label: 'Tiền hoa hồng'),
                const StatItemWidget(icon: Icons.phone_android, iconColor: Colors.blue, value: '0', label: 'Sử dụng app'),
                StatItemWidget(icon: Icons.account_balance_wallet, iconColor: Colors.red[400]!, value: '0', label: 'Cần quyết toán'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsCard() {
    return Card(
      elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.list_alt, color: Colors.orange, size: 24), SizedBox(width: 8),
                    Text('Đơn đặt lịch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                Text('Xem tất cả >', style: TextStyle(color: AppColors.primary, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircleActionButton(icon: Icons.pending_actions, label: 'Chờ duyệt', bgColor: Colors.pink[50]!, iconColor: AppColors.primary),
                CircleActionButton(icon: Icons.check_circle_outline, label: 'Đã duyệt', bgColor: Colors.pink[50]!, iconColor: AppColors.primary),
                CircleActionButton(icon: Icons.check_box_outlined, label: 'Hoàn thành', bgColor: Colors.pink[50]!, iconColor: AppColors.primary),
                CircleActionButton(icon: Icons.cancel_presentation, label: 'Yêu cầu hủy', bgColor: Colors.pink[50]!, iconColor: AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOptionsCard() {
    return Card(
      elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildListTile(Icons.grid_view, 'Cập nhật thông tin'),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildListTile(Icons.discount_outlined, 'Quản lý chương trình khuyến mãi'),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _buildListTile(Icons.info_outline, 'Thông tin dịch vụ'),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () {},
    );
  }
}