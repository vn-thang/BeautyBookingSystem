import 'package:flutter/material.dart';
import '../services/service_api.dart';
import '../models/service_group_model.dart';
import '../../../shared/widgets/shared_service_widgets.dart';

class ServiceGroupBottomSheet extends StatefulWidget {
  final int storeId;
  final ServiceGroupModel? group; // NẾU NULL -> Thêm mới, NẾU CÓ DATA -> Chỉnh sửa
  final VoidCallback onSuccess;

  const ServiceGroupBottomSheet({
    super.key,
    required this.storeId,
    this.group,
    required this.onSuccess,
  });

  @override
  State<ServiceGroupBottomSheet> createState() => _ServiceGroupBottomSheetState();
}

class _ServiceGroupBottomSheetState extends State<ServiceGroupBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isLoading = false;

  bool get isEdit => widget.group != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final nav = Navigator.of(context);

    try {
      if (isEdit) {
        await ServiceApi.updateServiceGroup(
          groupId: widget.group!.id,
          storeId: widget.storeId,
          name: _nameController.text.trim(),
          sortOrder: widget.group!.sortOrder,
        );
      } else {
        await ServiceApi.createServiceGroup(
          storeId: widget.storeId,
          name: _nameController.text.trim(),
        );
      }

      if (mounted) {
        nav.pop();
        SnackBarHelper.showSuccess(context, isEdit ? 'Cập nhật nhóm thành công!' : 'Tạo nhóm dịch vụ thành công!');
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BottomSheetHeader(title: isEdit ? 'Chỉnh sửa nhóm' : 'Thêm nhóm dịch vụ'),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: buildCustomInputDecoration(
                  isEdit ? 'Tên nhóm (*)' : 'Tên nhóm hiển thị (*)', 
                  'VD: Combo Cắt Tóc VIP...'
                ),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Vui lòng nhập tên nhóm' : null,
              ),
              const SizedBox(height: 32),
              LoadingSubmitButton(
                isLoading: _isLoading,
                onPressed: _submitForm,
                text: isEdit ? 'Lưu thay đổi' : 'Lưu nhóm dịch vụ',
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}