import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/service/media_service.dart';
import '../../../core/service/cloudinary_service.dart';

class AppImagePicker extends StatefulWidget {
  final String folderName; // Lưu vào thư mục nào? (avatars, services...)
  final String? initialImageUrl; // Link ảnh cũ (nếu đang trong chế độ Edit)
  final Function(String imageUrl) onImageUploaded; // Bắn link URL ra ngoài sau khi up xong
  final double width;
  final double height;
  final bool isCircle; // Avatar thì hình tròn, Ảnh dịch vụ thì hình vuông

  const AppImagePicker({
    super.key,
    required this.folderName,
    required this.onImageUploaded,
    this.initialImageUrl,
    this.width = 100,
    this.height = 100,
    this.isCircle = false,
  });

  @override
  State<AppImagePicker> createState() => _AppImagePickerState();
}

class _AppImagePickerState extends State<AppImagePicker> {
  bool _isUploading = false;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.initialImageUrl;
  }

  // --- HÀM XỬ LÝ KHI BẤM VÀO ---
  Future<void> _handlePickAndUpload() async {
    // 1. Chọn ảnh từ điện thoại (ở đây cấu hình chọn từ Thư viện)
    final File? file = await MediaService.pickImage(ImageSource.gallery);
    if (file == null) return; // Người dùng hủy chọn

    // 2. Cập nhật UI thành trạng thái Loading
    setState(() => _isUploading = true);

    // 3. Đẩy lên Firebase
    final String? uploadedUrl = await CloudinaryService.uploadImage(
      file,
      folderName: widget.folderName, 
    );
      if (!mounted) return;
    // 4. Cập nhật lại UI và bắn link ra ngoài
    setState(() {
      _isUploading = false;
      if (uploadedUrl != null) {
        _currentImageUrl = uploadedUrl;
      }
    });

    if (uploadedUrl != null) {
      widget.onImageUploaded(uploadedUrl); // Trả link về cho form cha (Ví dụ: form Dịch vụ)
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi tải ảnh lên!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isUploading ? null : _handlePickAndUpload, // Đang up thì không cho bấm liên tục
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: widget.isCircle ? null : BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 2),
          // Hiển thị ảnh nếu đã có link
          image: _currentImageUrl != null
              ? DecorationImage(
                  image: NetworkImage(_currentImageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _isUploading
            // Đang up -> Hiện vòng xoay
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            // Chưa có ảnh -> Hiện cái Icon camera
            : _currentImageUrl == null
                ? const Center(child: Icon(Icons.camera_alt, color: Colors.grey, size: 30))
                : null,
      ),
    );
  }
}