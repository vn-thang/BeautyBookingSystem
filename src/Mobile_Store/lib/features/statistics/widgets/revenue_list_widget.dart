import 'package:flutter/material.dart';
import 'package:mobile_store/features/booking/screens/booking_management_screen.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart'; 
import '../models/revenue_chart_item_model.dart';

class RevenueListWidget extends StatefulWidget {
  final List<RevenueChartItemModel> data;

  const RevenueListWidget({super.key, required this.data});

  @override
  State<RevenueListWidget> createState() => _RevenueListWidgetState();
}

class _RevenueListWidgetState extends State<RevenueListWidget> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  void _navigateToBookingList(String dateLabel) {
    DateTime? startDate;
    DateTime? endDate;

    try {
      if (dateLabel.length == 7 && dateLabel.contains('-')) {
        final parts = dateLabel.split('-');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        
        startDate = DateTime(year, month, 1);
        endDate = DateTime(year, month + 1, 0); 
      } 
      else {
        startDate = DateTime.parse(dateLabel);
        endDate = startDate; 
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingManagementScreen(
            initialIndex: 3,
            initialStartDate: startDate,
            initialEndDate: endDate,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Lỗi parse ngày tháng khi chuyển hướng: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final reversedList = widget.data.reversed.toList();

    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return RawScrollbar(
            controller: _horizontalController,
            thumbVisibility: true,
            thickness: 4,
            thumbColor: AppColors.surface,
            radius: const Radius.circular(AppDimens.radiusSmall),
            scrollbarOrientation: ScrollbarOrientation.bottom,
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: math.max(constraints.maxWidth, 320),
                child: RawScrollbar(
                  controller: _verticalController,
                  thumbVisibility: true,
                  thickness: 4,
                  thumbColor: AppColors.surface,
                  radius: const Radius.circular(AppDimens.radiusSmall),
                  child: SizedBox(
                    height: 250, 
                    child: ListView.separated(
                      controller: _verticalController,
                      shrinkWrap: false,
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.only(right: AppSpacing.md, bottom: AppSpacing.lg),
                      itemCount: reversedList.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.surface),
                      itemBuilder: (context, index) {
                        final item = reversedList[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _navigateToBookingList(item.dateLabel),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(AppSpacing.sm),
                                        decoration: const BoxDecoration(
                                          color: AppColors.surface, 
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.calendar_month_rounded, 
                                          size: 16, 
                                          color: AppColors.textSub,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.dateLabel, 
                                            style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${item.totalBookings} đơn hàng', 
                                            style: AppTextStyles.labelSmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    Formatters.formatCurrency(item.totalRevenue), 
                                    style: AppTextStyles.bodyText.copyWith(
                                      fontWeight: FontWeight.bold, 
                                      color: AppColors.primary, 
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}