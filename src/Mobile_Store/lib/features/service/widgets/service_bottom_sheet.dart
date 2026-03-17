import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/service_api.dart';
import '../models/global_category_model.dart';
import '../models/service_model.dart';
import '../../../shared/widgets/shared_service_widgets.dart';

// --- THÊM IMPORT NÀY ---
import '../../../shared/widgets/app_image_picker.dart'; 

class ServiceBottomSheet extends StatefulWidget {
  final int storeId;
  final ServiceModel? service; // NẾU NULL -> Thêm mới, NẾU CÓ DATA -> Chỉnh sửa
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
  
  // SỬA ĐỔI 1: Bỏ _imageUrlController, thay bằng biến String đơn giản
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
    
    // SỬA ĐỔI 2: Gán ảnh cũ (nếu có) vào biến _imageUrl
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
    // Đã xóa _imageUrlController nên không cần dispose nó nữa
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
          
          // SỬA ĐỔI 3: Truyền thẳng _imageUrl vào đây
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
          
          // SỬA ĐỔI 3: Truyền thẳng _imageUrl vào đây
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
              BottomSheetHeader(title: isEdit ? 'Chỉnh sửa dịch vụ' : 'Thêm dịch vụ mới'),
              const SizedBox(height: 4),
              Text('Thuộc nhóm: ${widget.groupName ?? "Dịch vụ tự do"}', style: const TextStyle(color: kPrimaryColor, fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 24),

              FutureBuilder<List<GlobalCategoryModel>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Không tải được danh mục', style: TextStyle(color: Colors.red));
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
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: buildCustomInputDecoration('Tên dịch vụ (*)', 'VD: Cắt Fade + Gội...'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Vui lòng nhập tên dịch vụ' : null,
              ),
              const SizedBox(height: 16),

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
                  const SizedBox(width: 16),
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
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: buildCustomInputDecoration('Mô tả dịch vụ (Không bắt buộc)', 'Nhập mô tả chi tiết...'),
              ),
              const SizedBox(height: 16),

              // SỬA ĐỔI 4: Thay thế TextFormField bằng AppImagePicker
              const Text('Hình ảnh dịch vụ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Center(
                child: AppImagePicker(
                  folderName: 'services', // Phân loại ảnh vào thư mục services trên Cloudinary
                  isCircle: false, // Để false để ảnh ra hình vuông bo góc, hợp với dịch vụ hơn
                  width: 120,
                  height: 120,
                  initialImageUrl: _imageUrl.isNotEmpty ? _imageUrl : null,
                  onImageUploaded: (url) {
                    setState(() {
                      _imageUrl = url; // Lưu link mới vào biến
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              if (isEdit) ...[
                Container(
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    activeThumbColor: kPrimaryColor,
                    title: const Text('Trạng thái hoạt động', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      _isActive ? 'Đang hiển thị cho khách đặt' : 'Đang tạm ẩn',
                      style: TextStyle(color: _isActive ? Colors.green : Colors.redAccent, fontSize: 12),
                    ),
                    value: _isActive,
                    onChanged: (val) => setState(() => _isActive = val),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              LoadingSubmitButton(
                isLoading: _isLoading,
                onPressed: _submitForm,
                text: isEdit ? 'Cập nhật dịch vụ' : 'Lưu dịch vụ',
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

