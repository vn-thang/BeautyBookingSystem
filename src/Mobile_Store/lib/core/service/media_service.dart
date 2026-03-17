import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class MediaService {
  static final ImagePicker _picker = ImagePicker();

  // Hàm chọn ảnh dùng chung
  static Future<File?> pickImage(ImageSource source) async {
    try {
      // imageQuality: 70 giúp nén ảnh gốc xuống còn khoảng 30% dung lượng
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70, 
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      debugPrint('Lỗi chọn ảnh: $e');
    }
    return null;
  }
}