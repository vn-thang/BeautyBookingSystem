import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/stat_item_widget.dart';
import '../models/store_dashboard_model.dart';

class DetailedStatsCard extends StatelessWidget {
  final StatisticsModel stats;
  final String currentFilter;
  final DateTime? startDate; // Đã thêm
  final DateTime? endDate;   // Đã thêm
  final ValueChanged<String> onFilterChanged;
  final Function(DateTime? startDate, DateTime? endDate) onDateChanged; // Đã sửa tên

  const DetailedStatsCard({
    super.key,
    required this.stats,
    required this.currentFilter,
    required this.startDate,
    required this.endDate,
    required this.onFilterChanged,
    required this.onDateChanged,
  });

  String _formatCurrency(double amount) {
    return amount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime initialDate = isStart 
        ? (startDate ?? DateTime.now()) 
        : (endDate ?? DateTime.now());
        
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Khi chọn 1 ngày, lập tức đẩy dữ liệu lên cho màn hình chính
      if (isStart) {
        onDateChanged(picked, endDate);
      } else {
        onDateChanged(startDate, picked);
      }
    }
  }

  Widget _buildDatePicker(BuildContext context, {required String label, required bool isStart}) {
    final date = isStart ? startDate : endDate;
    final dateString = date != null ? DateFormat('dd/MM/yyyy').format(date) : 'dd/mm/yyyy';

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectDate(context, isStart),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateString,
                    style: TextStyle(
                      fontSize: 14, 
                      color: date != null ? Colors.black87 : Colors.grey,
                    ),
                  ),
                  const Icon(Icons.calendar_month, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bar_chart, color: Colors.blue, size: 24),
                    SizedBox(width: 8),
                    Text('Thống kê chi tiết', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentFilter,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                      style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500),
                      items: const [
                        DropdownMenuItem(value: 'today', child: Text('Hôm nay')),
                        DropdownMenuItem(value: 'week', child: Text('Tuần này')),
                        DropdownMenuItem(value: 'month', child: Text('Tháng này')),
                        DropdownMenuItem(value: 'all', child: Text('Tất cả')), // ĐÃ THÊM MỤC NÀY
                        DropdownMenuItem(value: 'custom', child: Text('Tùy chỉnh')),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          onFilterChanged(newValue);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                _buildDatePicker(context, label: 'Bắt đầu', isStart: true),
                const SizedBox(width: 16),
                _buildDatePicker(context, label: 'Kết thúc', isStart: false),
              ],
            ),
            
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatItemWidget(icon: Icons.groups, iconColor: Colors.grey, value: '${stats.totalCustomers}', label: 'Khách hàng'),
                StatItemWidget(icon: Icons.calendar_month, iconColor: AppColors.primary, value: '${stats.totalBookings}', label: 'Lịch đặt'),
                StatItemWidget(icon: Icons.attach_money, iconColor: Colors.green, value: _formatCurrency(stats.totalRevenue), label: 'Doanh thu'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}