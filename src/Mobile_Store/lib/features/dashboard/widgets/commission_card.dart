import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/stat_item_widget.dart';
import '../models/store_dashboard_model.dart';

class CommissionCard extends StatelessWidget {
  final CommissionModel comm;
  const CommissionCard({super.key, required this.comm});

  String _formatCurrency(double amount) {
    return amount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

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
                StatItemWidget(icon: Icons.monetization_on, iconColor: Colors.yellow[700]!, value: _formatCurrency(comm.totalCommission), label: 'Hoa hồng'),
                StatItemWidget(icon: Icons.phone_android, iconColor: Colors.blue, value: _formatCurrency(comm.appUsageFee), label: 'Sử dụng app'),
                StatItemWidget(icon: Icons.account_balance_wallet, iconColor: Colors.red[400]!, value: _formatCurrency(comm.balanceToPay), label: 'Cần thanh toán'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}