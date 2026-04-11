import 'package:flutter/material.dart';
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
import '../models/staff_model.dart';
import '../models/staff_schedule_model.dart';
import '../services/staff_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/app_buttons.dart';

class StaffScheduleBottomSheet extends StatefulWidget {
  final StaffModel staff;

  const StaffScheduleBottomSheet({
    super.key,
    required this.staff,
  });

  @override
  State<StaffScheduleBottomSheet> createState() => _StaffScheduleBottomSheetState();
}

class _StaffScheduleBottomSheetState extends State<StaffScheduleBottomSheet> {
  List<StaffScheduleModel> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    try {
      final data = await StaffApi.getSchedules(widget.staff.id);
      
      if (data.isEmpty) {
        for (int i = 0; i <= 6; i++) {
          _schedules.add(StaffScheduleModel(
            dayOfWeek: i,
            startTime: const TimeOfDay(hour: 8, minute: 0),
            endTime: const TimeOfDay(hour: 17, minute: 0),
            isWorking: i != 0,
          ));
        }
      } else {
        _schedules = data;
      }
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(context, 'Lỗi tải lịch: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSchedules() async {
    Navigator.pop(context); 
    
    try {
      await StaffApi.updateSchedules(widget.staff.id, _schedules);
      if (!mounted) return;
      SnackBarHelper.showSuccess(context, 'Cập nhật lịch làm việc thành công!');
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(context, e.toString());
    }
  }

  Future<void> _selectTime(int index, bool isStart) async {
    final initialTime = isStart ? _schedules[index].startTime : _schedules[index].endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    
    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          _schedules[index].startTime = picked;
        } else {
          _schedules[index].endTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.8;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLarge)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.paddingLarge,
        left: AppDimens.paddingLarge,
        right: AppDimens.paddingLarge,
        top: AppDimens.paddingLarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
            ),
          ),
          Text('Lịch làm việc cố định', style: AppTextStyles.heading1.copyWith(fontSize: 20)),
          Text('Nhân viên: ${widget.staff.fullName}', style: AppTextStyles.bodyText.copyWith(color: AppColors.primary)),
          const SizedBox(height: AppSpacing.xl),

          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
          else
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _schedules.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.surface),
                itemBuilder: (context, index) {
                  final item = _schedules[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(item.dayName, style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w600)),
                        ),
                        Switch(
                          value: item.isWorking,
                          activeColor: AppColors.success,
                          onChanged: (val) => setState(() => item.isWorking = val),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: item.isWorking
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: () => _selectTime(index, true),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                                        child: Text(_formatTime(item.startTime), style: AppTextStyles.bodyText),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      child: Text('-'),
                                    ),
                                    InkWell(
                                      onTap: () => _selectTime(index, false),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                                        child: Text(_formatTime(item.endTime), style: AppTextStyles.bodyText),
                                      ),
                                    ),
                                  ],
                                )
                              : Align(
                                  alignment: Alignment.centerRight,
                                  child: Text('Nghỉ', style: AppTextStyles.bodyText.copyWith(color: AppColors.error, fontStyle: FontStyle.italic)),
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          
          const SizedBox(height: AppSpacing.xl),
          AppPrimaryButton(
            text: 'LƯU LỊCH',
            onPressed: _isLoading ? null : _saveSchedules,
          ),
        ],
      ),
    );
  }
}