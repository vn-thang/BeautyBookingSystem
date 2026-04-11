import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/store_createbooking_model.dart';

class Step2DateTimeWidget extends StatelessWidget {
  final DateTime? selectedDate;
  final String? selectedTime;
  final List<TimeSlotModel> availableTimeSlots;
  final bool isLoadingTimeSlots;
  final Function(DateTime) onDateSelected;
  final Function(String?) onTimeSelected;

  const Step2DateTimeWidget({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.availableTimeSlots,
    required this.isLoadingTimeSlots,
    required this.onDateSelected,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimens.paddingMedium),
      children: [
        Text('Ngày hẹn', style: AppTextStyles.heading1.copyWith(fontSize: 18)),
        const SizedBox(height: AppSpacing.sm),
        
        _buildDatePickerCard(context),
        
        const SizedBox(height: AppSpacing.xl),
        
        Text('Khung giờ khả dụng', style: AppTextStyles.heading1.copyWith(fontSize: 18)),
        const SizedBox(height: AppSpacing.md),
        
        if (selectedDate == null)
          _buildEmptyState(
            icon: Icons.calendar_today_outlined,
            message: 'Vui lòng chọn ngày để xem khung giờ',
            color: AppColors.textSub.withValues(alpha: 0.5),
          )
        else if (isLoadingTimeSlots)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          )
        else if (availableTimeSlots.isEmpty)
          _buildEmptyState(
            icon: Icons.event_busy_outlined,
            message: 'Cửa hàng đóng cửa hoặc\nđã kín lịch vào ngày này',
            color: Colors.red.shade300,
            textColor: Colors.red.shade400,
          )
        else
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: availableTimeSlots.map((slot) => _buildTimeSlotButton(slot)).toList(),
          ),
      ],
    );
  }

  Widget _buildDatePickerCard(BuildContext context) {
    final bool hasSelectedDate = selectedDate != null;
    
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(), 
          lastDate: DateTime.now().add(const Duration(days: 30)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: AppColors.primary),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onDateSelected(picked);
      },
      borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.paddingLarge),
        decoration: BoxDecoration(
          color: hasSelectedDate ? AppColors.primary.withValues(alpha: 0.05) : AppColors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          border: Border.all(
            color: hasSelectedDate ? AppColors.primary.withValues(alpha: 0.5) : AppColors.surface,
            width: hasSelectedDate ? 1.5 : 1.0,
          ),
          boxShadow: hasSelectedDate 
              ? [] 
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: hasSelectedDate ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_month, 
                color: hasSelectedDate ? AppColors.primary : AppColors.textSub,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasSelectedDate ? 'Đã chọn ngày' : 'Nhấn để chọn ngày', 
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSub)
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasSelectedDate 
                        ? DateFormat('EEEE, dd/MM/yyyy', 'vi').format(selectedDate!) 
                        : 'Chưa chọn',
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 16, 
                      color: hasSelectedDate ? AppColors.primary : AppColors.textMain
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSub.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotButton(TimeSlotModel slot) {
    bool isSelected = selectedTime == slot.time;
    bool canSelect = slot.isAvailable;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canSelect ? () => onTimeSelected(isSelected ? null : slot.time) : null,
        borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
        child: Ink(
          width: 80, 
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: !canSelect 
                ? Colors.grey.shade100 
                : (isSelected ? AppColors.primary : AppColors.white),
            borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
            border: Border.all(
              color: !canSelect 
                  ? Colors.grey.shade200 
                  : (isSelected ? AppColors.primary : AppColors.surface),
            ),
          ),
          child: Center(
            child: Text(
              slot.time,
              style: TextStyle(
                fontSize: 14,
                color: !canSelect 
                    ? Colors.grey.shade400 
                    : (isSelected ? AppColors.white : AppColors.textMain),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon, 
    required String message, 
    required Color color,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: AppSpacing.md),
            Text(
              message, 
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyText.copyWith(color: textColor ?? AppColors.textSub),
            ),
          ],
        ),
      ),
    );
  }
}