import 'package:flutter/material.dart';
import 'package:mobile_store/shared/widgets/buttons/app_buttons.dart';
import '../../../shared/widgets/feedback/snackbar_helper.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';

import '../models/store_booking_model.dart';
import '../services/store_booking_api.dart';

class AssignStaffBottomSheet extends StatefulWidget {
  final StoreBookingDetailModel booking;
  final VoidCallback onSuccess;

  const AssignStaffBottomSheet({super.key, required this.booking, required this.onSuccess});

  @override
  State<AssignStaffBottomSheet> createState() => _AssignStaffBottomSheetState();
}

class _AssignStaffBottomSheetState extends State<AssignStaffBottomSheet> {
  bool _isLoading = true;
  String? _errorMessage;

  final Map<int, List<AvailableStaffModel>> _availableStaffMap = {};
  final Map<int, int> _selectedStaffMap = {};

  @override
  void initState() {
    super.initState();
    _fetchAvailableStaffs();
  }

  Future<void> _fetchAvailableStaffs() async {
    try {
      for (var service in widget.booking.services) {
        final staffs = await StoreBookingApi.getAvailableStaffs(
          date: service.appointmentDate,
          startTime: service.startTime,
          endTime: service.endTime,
        );
        _availableStaffMap[service.bookingDetailId] = staffs;
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _submitAssignment() async {
    if (_selectedStaffMap.length < widget.booking.services.length) {
      SnackBarHelper.showError(context, 'Vui lòng phân công nhân viên cho tất cả dịch vụ!');
      return;
    }

    final assignments = _selectedStaffMap.entries.map((e) => {
      "bookingDetailId": e.key,
      "staffId": e.value
    }).toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    try {
      await StoreBookingApi.assignStaff(widget.booking.id, assignments);
      
      if (!mounted) return;
      Navigator.pop(context); 
      Navigator.pop(context); 
      
      widget.onSuccess(); 
      
      SnackBarHelper.showSuccess(context, 'Duyệt đơn & Gán nhân viên thành công!');
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); 
      SnackBarHelper.showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: AppSpacing.xl, left: AppDimens.paddingLarge, right: AppDimens.paddingLarge,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.paddingLarge,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLarge)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Phân công nhân viên', style: AppTextStyles.heading1.copyWith(fontSize: 20)),
              IconButton(icon: const Icon(Icons.close, color: AppColors.textMain), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          
          Expanded(child: _buildBody()),

          if (!_isLoading && _errorMessage == null) ...[
            const SizedBox(height: AppSpacing.lg),
            AppPrimaryButton(
              text: 'XÁC NHẬN VÀ DUYỆT ĐƠN',
              onPressed: _submitAssignment,
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_errorMessage != null) {
      return Center(child: Text('Lỗi: $_errorMessage', style: AppTextStyles.bodyText.copyWith(color: AppColors.error)));
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: widget.booking.services.length,
      separatorBuilder: (context, index) => const Divider(height: 32, color: AppColors.surface),
      itemBuilder: (context, index) {
        final service = widget.booking.services[index];
        final staffs = _availableStaffMap[service.bookingDetailId] ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.serviceName, style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '⏰ ${service.startTime} - ${service.endTime} • ${Formatters.formatDateOnly(service.appointmentDate)}',
              style: AppTextStyles.labelSmall,
            ),
            const SizedBox(height: AppSpacing.md),
            
            if (staffs.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1), 
                  borderRadius: BorderRadius.circular(AppDimens.radiusSmall)
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text('Không có nhân viên nào rảnh khung giờ này!', style: AppTextStyles.labelSmall.copyWith(color: AppColors.error, fontWeight: FontWeight.bold))),
                  ],
                ),
              )
            else
              DropdownButtonFormField<int>(
                dropdownColor: AppColors.white,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSub),
                decoration: InputDecoration(
                  labelText: 'Chọn nhân viên phụ trách',
                  labelStyle: AppTextStyles.labelSmall,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                    borderSide: BorderSide(color: AppColors.surface, width: 1.5)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusSmall),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5)
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                ),
                initialValue: _selectedStaffMap[service.bookingDetailId],
                items: staffs.map((staff) {
                  return DropdownMenuItem<int>(
                    value: staff.id,
                    child: Text('${staff.fullName} (${staff.position})', style: AppTextStyles.bodyText),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStaffMap[service.bookingDetailId] = value;
                    });
                  }
                },
              ),
          ],
        );
      },
    );
  }
}