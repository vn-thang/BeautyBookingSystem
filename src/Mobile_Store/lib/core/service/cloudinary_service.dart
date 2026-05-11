import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class BackendUploadService {
  static const String baseUrl = 'http://192.168.1.145:5294';

  static Future<String?> uploadImage(
    File imageFile, {
    String folderName = 'general',
  }) async {
    try {
      final Uri url = Uri.parse('$baseUrl/api/media/upload?folder=$folderName');

      final request = http.MultipartRequest('POST', url);

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonMap = jsonDecode(responseData);

      if (response.statusCode == 200) {
        return jsonMap['url'];
      } else {
        debugPrint('Lỗi từ Backend: ${response.statusCode} - $responseData');
        return null;
      }
    } catch (e) {
      debugPrint('Lỗi Exception khi gửi lên Backend: $e');
      return null;
    }
  }
}
