import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class CloudinaryService {
  static const String cloudName = 'drkpkiu7e'; 
  static const String uploadPreset = 'flutter_app_upload'; 

  static Future<String?> uploadImage(File imageFile, {String folderName = 'general'}) async {
    try {
      final Uri url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = folderName // Phân loại thư mục trên Cloudinary
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();

      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);

      if (response.statusCode == 200) {
        return jsonMap['secure_url'];
      } else {
        debugPrint('Lỗi từ Cloudinary: ${jsonMap['error']['message']}');
        return null;
      }
    } catch (e) {
      debugPrint('Lỗi Exception khi upload Cloudinary: $e');
      return null;
    }
  }
}