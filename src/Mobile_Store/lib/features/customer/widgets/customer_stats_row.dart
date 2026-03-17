import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer_profile_model.dart';

class CustomerStatsRow extends StatelessWidget {
  final CustomerProfileModel profile;

  const CustomerStatsRow({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Row(
      children: [
        _buildStatCard(
          title: 'Đã đến',
          value: '${profile.totalVisits}',
          unit: 'lần',
          icon: Icons.check_circle_outline,
          color: Colors.green,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          title: 'Chi tiêu',
          value: currencyFormat.format(profile.totalSpent),
          unit: '',
          icon: Icons.monetization_on_outlined,
          color: Colors.blue,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          title: 'Hủy lịch',
          value: '${profile.totalCancelled}',
          unit: 'lần',
          icon: Icons.cancel_outlined,
          // Bôi đỏ đậm nếu khách này hủy >= 3 lần (Cảnh báo bom hàng)
          color: profile.totalCancelled >= 3 ? Colors.red : Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              '$value ${unit}'.trim(),
              style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}