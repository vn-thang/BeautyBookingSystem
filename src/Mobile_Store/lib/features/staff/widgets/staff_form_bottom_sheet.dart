import 'package:flutter/material.dart';
import '../models/staff_model.dart';
import '../services/staff_api.dart';
import '../../../shared/widgets/app_image_picker.dart'; 

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
  final Color primaryColor = const Color(0xFFDE4660);

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

  void _showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  Future<void> _submitForm() async {
    if (_nameCtrl.text.trim().isEmpty || _positionCtrl.text.trim().isEmpty) {
      _showMessage('Vui lòng nhập tên và vị trí!', isError: true);
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
      _showMessage(isEdit ? 'Cập nhật thành công!' : 'Thêm thành công!');
      
    } catch (e) {
      _showMessage('Lỗi: $e', isError: true);
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEdit ? 'Sửa thông tin' : 'Thêm nhân viên mới', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
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
            const SizedBox(height: 20),

            TextField(controller: _nameCtrl, decoration: _buildInputDecoration('Tên nhân viên (*)')),
            const SizedBox(height: 16),
            
            TextField(controller: _positionCtrl, decoration: _buildInputDecoration('Vị trí (VD: Thợ chính, Thợ phụ) (*)')),
            const SizedBox(height: 16),

            if (isEdit) ...[
              SwitchListTile(
                title: const Text('Trạng thái hoạt động', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(_isActive ? 'Đang làm việc' : 'Đã nghỉ / Tạm ẩn', style: TextStyle(color: _isActive ? Colors.green : Colors.red)),
                value: _isActive,
                activeThumbColor: primaryColor,
                onChanged: (val) => setState(() => _isActive = val),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor, 
                  padding: const EdgeInsets.symmetric(vertical: 16), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isEdit ? 'LƯU THAY ĐỔI' : 'THÊM NHÂN VIÊN', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}