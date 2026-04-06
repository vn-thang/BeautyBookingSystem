import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/revenue_chart_item_model.dart';
import 'revenue_line_chart_widget.dart';
import 'revenue_list_widget.dart';

class RevenueChartCard extends StatefulWidget {
  final Future<List<RevenueChartItemModel>> future;
  final int selectedDays; 

  const RevenueChartCard({
    super.key,
    required this.future,
    this.selectedDays = 30,
  });

  @override
  State<RevenueChartCard> createState() => _RevenueChartCardState();
}

class _RevenueChartCardState extends State<RevenueChartCard> {
  bool _showChart = true;

  List<RevenueChartItemModel> _processData(List<RevenueChartItemModel> rawData) {
    List<RevenueChartItemModel> processedList = [];

    if (widget.selectedDays > 31) {
      Map<String, RevenueChartItemModel> groupedByMonth = {};
      for (var item in rawData) {
        final parts = item.dateLabel.split('-');
        if (parts.length >= 2) {
          final monthKey = '${parts[0]}-${parts[1]}';
          if (groupedByMonth.containsKey(monthKey)) {
            groupedByMonth[monthKey] = RevenueChartItemModel(
              dateLabel: monthKey,
              totalRevenue: groupedByMonth[monthKey]!.totalRevenue + item.totalRevenue,
              totalBookings: groupedByMonth[monthKey]!.totalBookings + item.totalBookings,
            );
          } else {
            groupedByMonth[monthKey] = RevenueChartItemModel(
              dateLabel: monthKey, 
              totalRevenue: item.totalRevenue, 
              totalBookings: item.totalBookings,
            );
          }
        }
      }
      processedList = groupedByMonth.values.toList();
    } else {
      processedList = List.from(rawData);
    }

    processedList.sort((a, b) => a.dateLabel.compareTo(b.dateLabel));
    return processedList;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      elevation: 4,
      shadowColor: AppColors.textMain.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1), 
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                  ),
                  child: const Icon(Icons.show_chart_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  'Doanh thu', 
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            Center(
              child: SegmentedButton<bool>(
                segments: [
                  ButtonSegment<bool>(
                    value: true, 
                    icon: const Icon(Icons.timeline_rounded), 
                    label: Text('Biểu đồ', style: AppTextStyles.bodyText),
                  ),
                  ButtonSegment<bool>(
                    value: false, 
                    icon: const Icon(Icons.list_alt_rounded), 
                    label: Text('Danh sách', style: AppTextStyles.bodyText),
                  ),
                ],
                selected: {_showChart},
                onSelectionChanged: (newSelection) => setState(() => _showChart = newSelection.first),
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  selectedForegroundColor: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppDimens.paddingLarge),

            FutureBuilder<List<RevenueChartItemModel>>(
              future: widget.future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 250, 
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  );
                }
                if (snapshot.hasError) {
                  return SizedBox(
                    height: 250, 
                    child: Center(
                      child: Text(
                        'Lỗi tải dữ liệu', 
                        style: AppTextStyles.bodyText.copyWith(color: AppColors.error),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SizedBox(
                    height: 250,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_long_rounded, size: 48, color: AppColors.textSub),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Chưa có giao dịch nào', 
                            style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final processedData = _processData(snapshot.data!);

                return AnimatedCrossFade(
                  firstChild: RevenueLineChartWidget(chartData: processedData),
                  secondChild: RevenueListWidget(data: processedData),
                  crossFadeState: _showChart ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 300),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}