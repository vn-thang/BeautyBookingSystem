import 'package:flutter/material.dart';
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
import '../models/staff_model.dart';
import '../services/staff_api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/inputs/app_image_picker.dart';
import '../../../shared/widgets/buttons/app_buttons.dart';
import '../../../shared/widgets/inputs/app_text_field.dart'; // Thêm import này

class StaffFormBottomSheet extends StatefulWidget {
  final StaffModel? staff;
  final VoidCallback onSuccess;

  const StaffFormBottomSheet({
    super.key,
    this.staff,
    required this.onSuccess,
  });

  @override
  State<StaffFormBottomSheet> createState() => _StaffFormBottomSheetState();
}

class _StaffFormBottomSheetState extends State<StaffFormBottomSheet> {
  final _nameCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  
  String _avatarUrl = ''; 
  bool _isActive = true;

  bool get isEdit => widget.staff != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _nameCtrl.text = widget.staff!.fullName;
      _positionCtrl.text = widget.staff!.position;
      _avatarUrl = widget.staff!.avatarUrl ?? '';
      _isActive = widget.staff!.isActive;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _positionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_nameCtrl.text.trim().isEmpty || _positionCtrl.text.trim().isEmpty) {
      SnackBarHelper.showError(context, 'Vui lòng nhập tên và vị trí!');
      return;
    }

    Navigator.pop(context); 

    try {
      if (isEdit) {
        await StaffApi.updateStaff(
          id: widget.staff!.id,
          fullName: _nameCtrl.text.trim(),
          position: _positionCtrl.text.trim(),
          avatarUrl: _avatarUrl, 
          isActive: _isActive,
        );
      } else {
        await StaffApi.createStaff(
          fullName: _nameCtrl.text.trim(),
          position: _positionCtrl.text.trim(),
          avatarUrl: _avatarUrl, 
        );
      }
      
      if (!mounted) return;
      widget.onSuccess();
      SnackBarHelper.showSuccess(context, isEdit ? 'Cập nhật thành công!' : 'Thêm thành công!');
      
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLarge)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppDimens.paddingLarge, 
        right: AppDimens.paddingLarge, 
        top: AppDimens.paddingLarge,
      ),
      child: SingleChildScrollView(
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
            Text(isEdit ? 'Sửa thông tin' : 'Thêm nhân viên mới', style: AppTextStyles.heading1.copyWith(fontSize: 20)),
            const SizedBox(height: AppSpacing.xl),
            
            Center(
              child: AppImagePicker(
                folderName: 'staff', 
                isCircle: true,      
                width: 100,          
                height: 100,
                initialImageUrl: _avatarUrl.isNotEmpty ? _avatarUrl : null,
                onImageUploaded: (url) {
                  setState(() {
                    _avatarUrl = url; 
                  });
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            AppTextField(
              controller: _nameCtrl, 
              label: 'Tên nhân viên (*)',
              hint: 'Nhập tên...',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            AppTextField(
              controller: _positionCtrl, 
              label: 'Vị trí (*)',
              hint: 'VD: Thợ chính, Thợ phụ...',
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: AppSpacing.lg),

            if (isEdit) ...[
              SwitchListTile(
                title: Text('Trạng thái hoạt động', style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  _isActive ? 'Đang làm việc' : 'Đã nghỉ / Tạm ẩn', 
                  style: AppTextStyles.labelSmall.copyWith(color: _isActive ? AppColors.success : AppColors.error)
                ),
                value: _isActive,
                activeThumbColor: AppColors.white,
                activeTrackColor: AppColors.success,
                inactiveThumbColor: AppColors.white,
                inactiveTrackColor: AppColors.textSub.withValues(alpha: 0.3),
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                onChanged: (val) => setState(() => _isActive = val),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            AppPrimaryButton(
              text: isEdit ? 'LƯU THAY ĐỔI' : 'THÊM NHÂN VIÊN',
              onPressed: _submitForm,
            ),
            const SizedBox(height: AppDimens.paddingLarge),
          ],
        ),
      ),
    );
  }
}