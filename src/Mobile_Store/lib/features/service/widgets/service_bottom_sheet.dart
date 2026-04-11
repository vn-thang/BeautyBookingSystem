import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_store/shared/widgets/feedback/snackbar_helper.dart';
import 'package:mobile_store/features/service/widgets/shared_service_widgets.dart' hide SnackBarHelper;
import '../services/service_api.dart';
import '../models/global_category_model.dart';
import '../../../shared/models/service_model.dart';
import '../../../shared/widgets/inputs/app_image_picker.dart'; 
import '../../../shared/widgets/buttons/app_buttons.dart'; 

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text_styles.dart';

class ServiceBottomSheet extends StatefulWidget {
  final int storeId;
  final ServiceModel? service; 
  final int? serviceGroupId;
  final String? groupName;
  final VoidCallback onSuccess;

  const ServiceBottomSheet({
    super.key,
    required this.storeId,
    this.service,
    this.serviceGroupId,
    this.groupName,
    required this.onSuccess,
  });

  @override
  State<ServiceBottomSheet> createState() => _ServiceBottomSheetState();
}

class _ServiceBottomSheetState extends State<ServiceBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late TextEditingController _descriptionController;
  
  String _imageUrl = ''; 

  late Future<List<GlobalCategoryModel>> _categoriesFuture;
  int? _selectedCategoryId;
  late bool _isActive;
  bool _isLoading = false;

  bool get isEdit => widget.service != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name ?? '');
    _priceController = TextEditingController(text: widget.service?.price.toInt().toString() ?? '');
    _durationController = TextEditingController(text: widget.service?.durationMinutes.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.service?.description ?? '');
    
    _imageUrl = widget.service?.imageUrl ?? '';

    _selectedCategoryId = widget.service?.categoryId;
    _isActive = widget.service?.isActive ?? true;

    _categoriesFuture = ServiceApi.getGlobalCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_selectedCategoryId == null) {
      SnackBarHelper.showError(context, 'Vui lòng chọn danh mục hệ thống!');
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final nav = Navigator.of(context);

    try {
      double price = double.tryParse(_priceController.text.replaceAll(',', '')) ?? 0.0;
      int duration = int.tryParse(_durationController.text) ?? 0;
      int? groupIdToSubmit = isEdit 
          ? (widget.service!.groupId == 0 ? null : widget.service!.groupId)
          : (widget.serviceGroupId == 0 || widget.serviceGroupId == -1) ? null : widget.serviceGroupId;

      if (isEdit) {
        await ServiceApi.updateService(
          storeId: widget.storeId,
          serviceId: widget.service!.id,
          categoryId: _selectedCategoryId!,
          groupId: groupIdToSubmit ?? 0,
          name: _nameController.text.trim(),
          price: price,
          durationMinutes: duration,
          description: _descriptionController.text.trim(),
          imageUrl: _imageUrl, 
          isActive: _isActive,
        );
      } else {
        await ServiceApi.createService(
          storeId: widget.storeId,
          categoryId: _selectedCategoryId!,
          groupId: groupIdToSubmit,
          name: _nameController.text.trim(),
          price: price,
          durationMinutes: duration,
          description: _descriptionController.text.trim(),
          imageUrl: _imageUrl, 
        );
      }

      if (mounted) {
        nav.pop();
        SnackBarHelper.showSuccess(context, isEdit ? 'Cập nhật dịch vụ thành công!' : 'Thêm dịch vụ thành công!');
        widget.onSuccess();
      }
    } catch (e) {
      if (mounted) SnackBarHelper.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
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
            BottomSheetHeader(title: isEdit ? 'Chỉnh sửa dịch vụ' : 'Thêm dịch vụ mới'),
            const SizedBox(height: 4),
            Text(
              'Thuộc nhóm: ${widget.groupName ?? "Dịch vụ tự do"}', 
              style: AppTextStyles.bodyText.copyWith(color: AppColors.primary)
            ),
            const SizedBox(height: AppDimens.paddingLarge),

            FutureBuilder<List<GlobalCategoryModel>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Không tải được danh mục', style: AppTextStyles.bodyText.copyWith(color: AppColors.error));
                }
                
                bool idExists = snapshot.data!.any((cat) => cat.id == _selectedCategoryId);
                return DropdownButtonFormField<int>(
                  decoration: buildCustomInputDecoration('Danh mục hệ thống (*)', 'Chọn danh mục...'),
                  initialValue: idExists ? _selectedCategoryId : null,
                  items: snapshot.data!.map((cat) => DropdownMenuItem<int>(value: cat.id, child: Text(cat.name))).toList(),
                  onChanged: (val) => setState(() => _selectedCategoryId = val),
                  validator: (value) => value == null ? 'Vui lòng chọn danh mục' : null,
                );
              },
            ),
            const SizedBox(height: AppDimens.paddingMedium),

            TextFormField(
              controller: _nameController,
              decoration: buildCustomInputDecoration('Tên dịch vụ (*)', 'VD: Cắt Fade + Gội...'),
              validator: (value) => (value == null || value.trim().isEmpty) ? 'Vui lòng nhập tên dịch vụ' : null,
            ),
            const SizedBox(height: AppDimens.paddingMedium),

            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: buildCustomInputDecoration('Giá tiền (VNĐ)', 'VD: 100000'),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Nhập giá' : null,
                  ),
                ),
                const SizedBox(width: AppDimens.paddingMedium),
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: buildCustomInputDecoration('Thời gian', 'Phút (VD: 45)'),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Nhập phút' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.paddingMedium),

            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: buildCustomInputDecoration('Mô tả dịch vụ (Không bắt buộc)', 'Nhập mô tả chi tiết...'),
            ),
            const SizedBox(height: AppDimens.paddingMedium),

            Text('Hình ảnh dịch vụ', style: AppTextStyles.labelSmall),
            const SizedBox(height: AppDimens.paddingSmall),
            Center(
              child: AppImagePicker(
                folderName: 'services', 
                isCircle: false,
                width: 120,
                height: 120,
                initialImageUrl: _imageUrl.isNotEmpty ? _imageUrl : null,
                onImageUploaded: (url) {
                  setState(() {
                    _imageUrl = url; 
                  });
                },
              ),
            ),
            const SizedBox(height: AppDimens.paddingMedium),

            if (isEdit) ...[
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background, 
                  borderRadius: BorderRadius.circular(AppDimens.radiusMedium)
                ),
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMedium, vertical: 4),
                  activeThumbColor: AppColors.primary,
                  title: Text('Trạng thái hoạt động', style: AppTextStyles.labelSmall),
                  subtitle: Text(
                    _isActive ? 'Đang hiển thị cho khách đặt' : 'Đang tạm ẩn',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _isActive ? AppColors.success : AppColors.error
                    ),
                  ),
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val),
                ),
              ),
              const SizedBox(height: AppDimens.paddingLarge),
            ],

            AppPrimaryButton(
              text: isEdit ? 'CẬP NHẬT DỊCH VỤ' : 'LƯU DỊCH VỤ',
              isLoading: _isLoading,
              onPressed: _submitForm,
            ),
            const SizedBox(height: AppDimens.paddingLarge),
          ],
        ),
      ),
    );
  }
}