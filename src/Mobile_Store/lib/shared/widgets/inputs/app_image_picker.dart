import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_store/core/service/cloudinary_service.dart';
import 'package:mobile_store/core/theme/app_colors.dart';
import '../../../core/service/media_service.dart'; 

class AppImagePicker extends StatefulWidget {
  final String folderName; 
  final String? initialImageUrl; 
  final Function(String imageUrl) onImageUploaded; 
  final double width;
  final double height;
  final bool isCircle; 

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
@override
void didUpdateWidget(AppImagePicker oldWidget) {
  super.didUpdateWidget(oldWidget);

  if (oldWidget.initialImageUrl != widget.initialImageUrl) {
    setState(() {
      _currentImageUrl = widget.initialImageUrl;
    });
  }
}

  Future<void> _handlePickAndUpload() async {
    final File? file = await MediaService.pickImage(ImageSource.gallery);
    if (file == null) return;

    setState(() => _isUploading = true);

    final String? uploadedUrl = await BackendUploadService.uploadImage(
      file,
      folderName: widget.folderName, 
    );
    
    if (!mounted) return;
    
    setState(() {
      _isUploading = false;
      if (uploadedUrl != null) {
        _currentImageUrl = uploadedUrl; 
      }
    });

    if (uploadedUrl != null) {
      widget.onImageUploaded(uploadedUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi tải ảnh lên Server! Vui lòng thử lại.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isUploading ? null : _handlePickAndUpload, 
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: widget.isCircle ? null : BorderRadius.circular(12),
          border: Border.all(color: AppColors.surface, width: 2),
          image: _currentImageUrl != null
              ? DecorationImage(
                  image: NetworkImage(_currentImageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _isUploading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : _currentImageUrl == null
               ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ← Sửa màu icon
                      Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.grey[400],
                        size: 30,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Thêm ảnh',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                : null,
      ),
    );
  }
}