import 'package:flutter/material.dart';
import 'package:mobile_store/shared/widgets/inputs/app_filter_dropdown.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart'; 
import '../../../shared/widgets/cards/stat_item_widget.dart';
import '../models/store_dashboard_model.dart';

class DetailedStatsCard extends StatelessWidget {
  final StatisticsModel stats;
  final String currentFilter;
  final DateTime? startDate; 
  final DateTime? endDate;   
  final ValueChanged<String> onFilterChanged;
  final Function(DateTime? startDate, DateTime? endDate) onDateChanged; 

  const DetailedStatsCard({
    super.key,
    required this.stats,
    required this.currentFilter,
    required this.startDate,
    required this.endDate,
    required this.onFilterChanged,
    required this.onDateChanged,
  });

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
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textMain,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStart) {
        onDateChanged(picked, endDate);
      } else {
        onDateChanged(startDate, picked);
      }
    }
  }

  Widget _buildDatePicker(BuildContext context, {required String label, required bool isStart}) {
    final date = isStart ? startDate : endDate;
    final dateString = date != null ? Formatters.formatDateOnly(date) : 'dd/mm/yyyy';

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label, 
            style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w500, color: AppColors.textMain)
          ),
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: () => _selectDate(context, isStart),
            borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingSmall, vertical: AppDimens.paddingSmall),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.textSub.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded( 
      child: Text(
        dateString,
        style: AppTextStyles.bodyText.copyWith(
          color: date != null ? AppColors.textMain : AppColors.textSub,
          fontSize: 13, 
        ),
        overflow: TextOverflow.ellipsis, 
        maxLines: 1,
      ),
    ),
    const SizedBox(width: 4), 
                  const Icon(Icons.calendar_month, size: 18, color: AppColors.textSub),
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
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.bar_chart, color: AppColors.primary, size: 24),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          'Thống kê chi tiết', 
                          style: AppTextStyles.bodyText.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis, 
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 8), 
                
                SizedBox(
                  width: 130, 
                  child: AppFilterDropdown<String>(
                    hint: 'Tất cả',
                    value: currentFilter,
                    items: const [
                      DropdownMenuItem(value: 'today', child: Text('Hôm nay')),
                      DropdownMenuItem(value: 'week', child: Text('Tuần này')),
                      DropdownMenuItem(value: 'month', child: Text('Tháng này')),
                      DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                      DropdownMenuItem(value: 'custom', child: Text('Tùy chỉnh')),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        onFilterChanged(newValue);
                      }
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            Row(
              children: [
                _buildDatePicker(context, label: 'Bắt đầu', isStart: true),
                const SizedBox(width: AppSpacing.lg),
                _buildDatePicker(context, label: 'Kết thúc', isStart: false),
              ],
            ),
            
            const SizedBox(height: AppDimens.paddingLarge),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatItemWidget(icon: Icons.groups, iconColor: AppColors.textSub, value: '${stats.totalCustomers}', label: 'Khách hàng'),
                StatItemWidget(icon: Icons.calendar_month, iconColor: AppColors.primary, value: '${stats.totalBookings}', label: 'Lịch đặt'),
                StatItemWidget(icon: Icons.attach_money, iconColor: AppColors.success, value: Formatters.formatCurrency(stats.totalRevenue), label: 'Doanh thu'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}