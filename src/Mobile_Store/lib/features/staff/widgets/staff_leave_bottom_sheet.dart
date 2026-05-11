import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
import '../models/staff_model.dart';
import '../models/staff_leave_model.dart';
import '../services/staff_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/buttons/app_buttons.dart';
import '../../../shared/widgets/inputs/app_text_field.dart';

class StaffLeaveBottomSheet extends StatefulWidget {
  final StaffModel staff;

  const StaffLeaveBottomSheet({
    super.key,
    required this.staff,
  });

  @override
  State<StaffLeaveBottomSheet> createState() => _StaffLeaveBottomSheetState();
}

class _StaffLeaveBottomSheetState extends State<StaffLeaveBottomSheet> {
  final _reasonCtrl = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;
  
  List<StaffLeaveModel> _leaves = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadLeaves();
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLeaves() async {
    try {
      final data = await StaffApi.getLeaves(widget.staff.id);
      if (mounted) setState(() => _leaves = data);
    } catch (e) {
      if (mounted) SnackBarHelper.showError(context, 'Lỗi tải danh sách: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDateTime(bool isFrom) async {
    final DateTime initialDate = isFrom 
        ? (_fromDate ?? DateTime.now()) 
        : (_toDate ?? _fromDate ?? DateTime.now());

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)), 
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          final finalDateTime = DateTime(
            pickedDate.year, pickedDate.month, pickedDate.day,
            pickedTime.hour, pickedTime.minute,
          );
          
          if (isFrom) {
            _fromDate = finalDateTime;
            if (_toDate != null && _toDate!.isBefore(_fromDate!)) {
              _toDate = _fromDate!.add(const Duration(hours: 4)); 
            }
          } else {
            _toDate = finalDateTime;
          }
        });
      }
    }
  }

  Future<void> _submitLeave() async {
    if (_fromDate == null || _toDate == null) {
      SnackBarHelper.showError(context, 'Vui lòng chọn thời gian bắt đầu và kết thúc!');
      return;
    }
    if (_toDate!.isBefore(_fromDate!) || _toDate!.isAtSameMomentAs(_fromDate!)) {
      SnackBarHelper.showError(context, 'Thời gian kết thúc phải lớn hơn thời gian bắt đầu!');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await StaffApi.createLeave(
        staffId: widget.staff.id,
        fromDate: _fromDate!,
        toDate: _toDate!,
        reason: _reasonCtrl.text.trim(),
      );
      
      if (!mounted) return;
      SnackBarHelper.showSuccess(context, 'Đã thêm ngày nghỉ thành công!');
      
      _fromDate = null;
      _toDate = null;
      _reasonCtrl.clear();
      await _loadLeaves();
      
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(context, e.toString()); 
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _deleteLeave(int leaveId) async {
    try {
      await StaffApi.deleteLeave(widget.staff.id, leaveId);
      if (!mounted) return;
      SnackBarHelper.showSuccess(context, 'Đã xóa đơn xin nghỉ!');
      _loadLeaves();
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

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
          Text('Xin nghỉ phép đột xuất', style: AppTextStyles.heading1.copyWith(fontSize: 20)),
          Text('Nhân viên: ${widget.staff.fullName}', style: AppTextStyles.bodyText.copyWith(color: AppColors.primary)),
          const SizedBox(height: AppSpacing.xl),

         Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDateTime(true),
                  child: IgnorePointer(
                    child: AppTextField(
                      controller: TextEditingController(text: _fromDate != null ? DateFormat('dd/MM/yyyy HH:mm').format(_fromDate!) : ''),
                      label: 'Từ lúc (*)',
                      hint: 'Chọn thời gian...',
                      icon: Icons.calendar_today_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDateTime(false),
                  child: IgnorePointer(
                    child: AppTextField(
                      controller: TextEditingController(text: _toDate != null ? DateFormat('dd/MM/yyyy HH:mm').format(_toDate!) : ''),
                      label: 'Đến lúc (*)',
                      hint: 'Chọn thời gian...',
                      icon: Icons.event_available_outlined,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _reasonCtrl,
            label: 'Lý do nghỉ (Tùy chọn)',
            hint: 'VD: Khám bệnh, Việc gia đình...',
            icon: Icons.edit_note_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          
          AppPrimaryButton(
            text: _isSubmitting ? 'ĐANG LƯU...' : 'THÊM NGÀY NGHỈ',
            onPressed: _isSubmitting ? null : _submitLeave,
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(color: AppColors.surface, thickness: 2),
          ),
          
          Text('Lịch sử nghỉ phép', style: AppTextStyles.heading1.copyWith(fontSize: 16)),
          const SizedBox(height: AppSpacing.sm),

          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
          else if (_leaves.isEmpty)
            Expanded(
              child: Center(
                child: Text('Chưa có dữ liệu nghỉ phép.', style: AppTextStyles.bodyText.copyWith(color: AppColors.textSub)),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _leaves.length,
                itemBuilder: (context, index) {
                  final leave = _leaves[index];
                  final isPast = leave.toDate.isBefore(DateTime.now());

                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    color: AppColors.surface.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                      leading: Icon(Icons.event_busy, color: isPast ? AppColors.textSub : AppColors.error),
                      title: Text(
                        '${DateFormat('HH:mm dd/MM').format(leave.fromDate)} - ${DateFormat('HH:mm dd/MM').format(leave.toDate)}',
                        style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, color: isPast ? AppColors.textSub : AppColors.textMain),
                      ),
                      subtitle: leave.reason != null && leave.reason!.isNotEmpty
                          ? Text(leave.reason!, style: AppTextStyles.labelSmall)
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () => _deleteLeave(leave.id),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}