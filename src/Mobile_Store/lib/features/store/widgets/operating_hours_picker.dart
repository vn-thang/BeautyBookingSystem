import 'package:flutter/material.dart';
import '../models/operating_hour.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../shared/widgets/feedback/snackbar_helper.dart'; 

class OperatingHoursPicker extends StatefulWidget {
  final List<OperatingHour> operatingHours;
  final Color primaryColor;

  const OperatingHoursPicker({
    super.key,
    required this.operatingHours,
    required this.primaryColor,
  });

  @override
  State<OperatingHoursPicker> createState() => _OperatingHoursPickerState();
}

class _OperatingHoursPickerState extends State<OperatingHoursPicker> {
  final List<String> _days = [
    "Chủ nhật", "Thứ 2", "Thứ 3", "Thứ 4", "Thứ 5", "Thứ 6", "Thứ 7"
  ];

  Future<void> _pickTime(OperatingHour day, bool isOpeningTime) async {
    final timeString = isOpeningTime ? day.openTime : day.closeTime;
    final parts = timeString.split(':');

    TimeOfDay initialTime = (parts.length == 2)
        ? TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 8,
            minute: int.tryParse(parts[1]) ?? 0,
          )
        : TimeOfDay.now();

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: isOpeningTime ? 'Chọn giờ mở cửa' : 'Chọn giờ đóng cửa',
    );

    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

      setState(() {
        if (isOpeningTime) {
          day.openTime = formattedTime;
        } else {
          day.closeTime = formattedTime;
        }

        final openParts = day.openTime.split(':');
        final closeParts = day.closeTime.split(':');
        
        if (openParts.length == 2 && closeParts.length == 2) {
           final openMinutes = int.parse(openParts[0]) * 60 + int.parse(openParts[1]);
           final closeMinutes = int.parse(closeParts[0]) * 60 + int.parse(closeParts[1]);

           if (openMinutes >= closeMinutes) {
             SnackBarHelper.showError(context, "Giờ đóng cửa đang sớm hơn hoặc bằng giờ mở cửa!");
           }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading: Icon(Icons.calendar_month_outlined, color: widget.primaryColor),
        title: Text("Chi tiết giờ hoạt động (7 ngày)",
            style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w600)),
        children: List.generate(widget.operatingHours.length, (index) {
          final day = widget.operatingHours[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 16, right: 16),
            child: Row(
              children: [
                Checkbox(
                  value: day.isActive,
                  activeColor: widget.primaryColor,
                  onChanged: (val) => setState(() => day.isActive = val ?? false),
                ),
                SizedBox(
                    width: 70,
                    child: Text(_days[day.dayOfWeek],
                        style: AppTextStyles.bodyText.copyWith(fontSize: 13))),
                if (day.isActive) ...[
                  Expanded(
                      child: _buildTimeBox(
                          day.openTime, () => _pickTime(day, true))),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text("-", style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub))),
                  Expanded(
                      child: _buildTimeBox(
                          day.closeTime, () => _pickTime(day, false))),
                ] else
                  Expanded(
                      child: Text(" Nghỉ",
                          style: AppTextStyles.bodyText.copyWith(
                              color: AppColors.error,
                              fontStyle: FontStyle.italic,
                              fontSize: 13))),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Khung chứa giờ
  Widget _buildTimeBox(String time, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
            border: Border.all(color: AppColors.surface, width: 1.5),
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
        alignment: Alignment.center,
        child: Text(time, style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w500)),
      ),
    );
  }
}