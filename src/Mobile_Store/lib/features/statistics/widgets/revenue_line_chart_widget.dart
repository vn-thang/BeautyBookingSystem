import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart'; 
import '../models/revenue_chart_item_model.dart';

class RevenueLineChartWidget extends StatefulWidget {
  final List<RevenueChartItemModel> chartData;

  const RevenueLineChartWidget({super.key, required this.chartData});

  @override
  State<RevenueLineChartWidget> createState() => _RevenueLineChartWidgetState();
}

class _RevenueLineChartWidgetState extends State<RevenueLineChartWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compactFormat = NumberFormat.compact(locale: 'vi_VN');

    double maxRevenue = 0;
    for (var item in widget.chartData) {
      if (item.totalRevenue > maxRevenue) maxRevenue = item.totalRevenue;
    }
    if (maxRevenue == 0) maxRevenue = 100000;

    final screenWidth = MediaQuery.of(context).size.width;
    final chartWidth = math.max(screenWidth - 80, widget.chartData.length * 45.0);

    return SizedBox(
      height: 250,
      child: RawScrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        thickness: 4,
        thumbColor: AppColors.textSub.withValues(alpha: 0.4),
        radius: const Radius.circular(AppDimens.radiusSmall),
        scrollbarOrientation: ScrollbarOrientation.bottom,
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Container(
            width: chartWidth,
            padding: const EdgeInsets.only(
              right: AppDimens.paddingLarge, 
              left: AppSpacing.xs, 
              top: 40.0, 
              bottom: AppDimens.paddingMedium,
            ),
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxRevenue * 1.25,
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => AppColors.textMain,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final index = touchedSpot.x.toInt();
                        return LineTooltipItem(
                          '${widget.chartData[index].dateLabel}\n',
                          AppTextStyles.labelSmall.copyWith(
                            color: AppColors.white, 
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                              text: Formatters.formatCurrency(touchedSpot.y), 
                              style: AppTextStyles.bodyText.copyWith(
                                color: AppColors.primary, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.surface, 
                    strokeWidth: 1, 
                    dashArray: [5, 5],
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < widget.chartData.length) {
                          final dateParts = widget.chartData[index].dateLabel.split('-');
                          final shortDate = dateParts.length >= 3
                              ? '${dateParts[2]}/${dateParts[1]}'
                              : '${dateParts[1]}/${dateParts[0].substring(2)}';

                          return Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: Text(
                              shortDate, 
                              style: AppTextStyles.labelSmall.copyWith(
                                fontSize: 10, 
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 55,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value == 0) return const Text('');
                        return Text(
                          compactFormat.format(value), 
                          style: AppTextStyles.labelSmall.copyWith(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(widget.chartData.length, (index) {
                      return FlSpot(index.toDouble(), widget.chartData[index].totalRevenue);
                    }),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.3),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}