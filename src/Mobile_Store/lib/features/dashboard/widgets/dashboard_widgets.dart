import 'package:flutter/material.dart';
import 'package:mobile_store/features/booking/screens/booking_management_screen.dart';
import '../../../core/theme/app_colors.dart'; 
import 'package:mobile_store/shared/widgets/stat_item_widget.dart';
import 'package:mobile_store/shared/widgets/circle_action_button.dart';
import '../../store/screens/update_profile_screen.dart';

String _formatCurrency(dynamic amount) {
  if (amount == null) return '0';
  double value = double.tryParse(amount.toString()) ?? 0;
  return value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
}

class PendingBanner extends StatelessWidget {
  const PendingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.orange.shade100,
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tài khoản đang chờ duyệt. Một số tính năng thống kê tạm thời bị khóa.',
              style: TextStyle(color: Colors.orange.shade900, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardHeader extends StatelessWidget {
  final Map<String, dynamic> headerData;
  const DashboardHeader({super.key, required this.headerData});

  @override
  Widget build(BuildContext context) {
    final storeName = headerData['name'] ?? 'Chưa cập nhật tên';
    final address = headerData['address'] ?? 'Chưa cập nhật địa chỉ';
    final logoUrl = headerData['logoUrl']?.toString() ?? '';
    
    return Material(
      color: AppColors.primary,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      clipBehavior: Clip.antiAlias, // Để cắt ảnh nền bo tròn theo viền
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UpdateProfileScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 55, height: 55, color: Colors.white24,
                  child: logoUrl.isNotEmpty
                      ? Image.network(
                          logoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(Icons.store, color: Colors.white, size: 30),
                        )
                      : const Icon(Icons.store, color: Colors.white, size: 30),
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            storeName, 
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14), 
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Địa chỉ: $address', 
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13), 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis
                    ),
                  ],
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}

class DetailedStatsCard extends StatelessWidget {
  final Map<String, dynamic> stats;
  const DetailedStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.bar_chart, color: Colors.blue, size: 24), SizedBox(width: 8),
                Text('Thống kê chi tiết', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDatePickerField('Bắt đầu', '10/1/2024')),
                const SizedBox(width: 16),
                Expanded(child: _buildDatePickerField('Kết thúc', '17/1/2024')),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatItemWidget(icon: Icons.groups, iconColor: Colors.grey, value: '${stats['totalCustomers'] ?? 0}', label: 'Khách hàng'),
                StatItemWidget(icon: Icons.calendar_month, iconColor: AppColors.primary, value: '${stats['totalBookings'] ?? 0}', label: 'Lịch đặt'),
                StatItemWidget(icon: Icons.attach_money, iconColor: Colors.green, value: _formatCurrency(stats['totalRevenue']), label: 'Doanh thu'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerField(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              const Icon(Icons.calendar_month, size: 18, color: Colors.black54),
            ],
          ),
        ),
      ],
    );
  }
}

class CommissionCard extends StatelessWidget {
  final Map<String, dynamic> comm;
  const CommissionCard({super.key, required this.comm});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.pie_chart, color: Colors.orange, size: 24), SizedBox(width: 8),
                    Text('Thống kê tiền hoa hồng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                Text('Xem tất cả >', style: TextStyle(color: AppColors.primary, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatItemWidget(icon: Icons.monetization_on, iconColor: Colors.yellow[700]!, value: _formatCurrency(comm['totalCommission']), label: 'Tiền hoa hồng'),
                StatItemWidget(icon: Icons.phone_android, iconColor: Colors.blue, value: _formatCurrency(comm['appUsageFee']), label: 'Sử dụng app'),
                StatItemWidget(icon: Icons.account_balance_wallet, iconColor: Colors.red[400]!, value: _formatCurrency(comm['balanceToPay']), label: 'Cần quyết toán'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BookingsCard extends StatelessWidget {
  final Map<String, dynamic> counts;
  final VoidCallback onViewAllBookings; 
  
  const BookingsCard({
    super.key, 
    required this.counts,
    required this.onViewAllBookings, 
  });

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
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BookingManagementScreen(initialIndex: 1)),
        );
      },
      child: CircleActionButton(
        icon: Icons.pending_actions, 
        label: 'Chờ duyệt\n(${counts['pending'] ?? 0})', 
        bgColor: Colors.pink[50]!, 
        iconColor: AppColors.primary
      ),
    ),

    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BookingManagementScreen(initialIndex: 2)),
        );
      },
      child: CircleActionButton(
        icon: Icons.check_circle_outline, 
        label: 'Đã xác nhận\n(${counts['confirmed'] ?? 0})', 
        bgColor: Colors.pink[50]!, 
        iconColor: AppColors.primary
      ),
    ),

    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BookingManagementScreen(initialIndex: 3)),
        );
      },
      child: CircleActionButton(
        icon: Icons.check_box_outlined, 
        label: 'Hoàn thành\n(${counts['completed'] ?? 0})', 
        bgColor: Colors.pink[50]!, 
        iconColor: AppColors.primary
      ),
    ),

    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BookingManagementScreen(initialIndex: 4)),
        );
      },
      child: CircleActionButton(
        icon: Icons.cancel_presentation, 
        label: 'Khách hủy\n(${counts['cancelledByCustomer'] ?? 0})', 
        bgColor: Colors.pink[50]!, 
        iconColor: AppColors.primary
      ),
    ),
  ],
)
          ],
        ),
      ),
    );
  }
}
